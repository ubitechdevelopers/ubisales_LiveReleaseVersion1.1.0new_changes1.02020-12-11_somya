package org.ubitech.attendance;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.location.LocationManager;
import android.os.Binder;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.provider.Settings;
import android.util.Log;

import androidx.core.app.NotificationCompat;

import java.util.HashMap;
import java.util.concurrent.TimeUnit;

import io.flutter.plugin.common.MethodChannel;

public class BackgroundLocationService extends Service {
    private final LocationServiceBinder binder = new LocationServiceBinder();
    private final String TAG = "BackgroundLocationService";
    private LocationListener mLocationListener;
    private LocationManager mLocationManager;
    private NotificationManager notificationManager;

    private final int LOCATION_INTERVAL = 500;
    private final int LOCATION_DISTANCE = 10;
    private boolean mockLocationsEnabled;
    private Location lastMockLocation;
    private int numGoodReadings;

    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    private void checkMockLocations() {
        // Starting with API level >= 18 we can (partially) rely on .isFromMockProvider()
        // (http://developer.android.com/reference/android/location/Location.html#isFromMockProvider%28%29)
        // For API level < 18 we have to check the Settings.Secure flag
        //checkInternet();
        if (Build.VERSION.SDK_INT < 18 &&
                !Settings.Secure.getString(getApplicationContext().getContentResolver(), Settings
                        .Secure.ALLOW_MOCK_LOCATION).equals("0")) {
            mockLocationsEnabled = true;

        } else
            mockLocationsEnabled = false;

        Log.i("shashank","checking Mock Location "+mockLocationsEnabled);
    }
    private boolean isLocationPlausible(Location location) {
        checkMockLocations();
        if (location == null) return false;

        boolean isMock = mockLocationsEnabled || (Build.VERSION.SDK_INT >= 18 && location.isFromMockProvider());
        if (isMock) {
            lastMockLocation = location;
            numGoodReadings = 0;
        } else
            numGoodReadings = Math.min(numGoodReadings + 1, 1000000); // Prevent overflow

        // We only clear that incident record after a significant show of good behavior
        if (numGoodReadings >= 20) lastMockLocation = null;

        // If there's nothing to compare against, we have to trust it
        if (lastMockLocation == null) return true;

        // And finally, if it's more than 1km away from the last known mock, we'll trust it
        double d = location.distanceTo(lastMockLocation);
        return (d > 1000);
    }

    private class LocationListener implements android.location.LocationListener
    {
        private Location lastLocation = null;
        private final String TAG = "LocationListener";
        private Location mLastLocation;
        private long previousTime=0,currentTime=0;
        private boolean timeSpoofed;
        private String ifMocked;
        MethodChannel methodChannel;

        public LocationListener(String provider, MethodChannel methodChannel)
        {
            mLastLocation = new Location(provider);
            this.methodChannel=methodChannel;
        }

        @Override
        public void onLocationChanged(Location location)
        {
            boolean plausible=true;
            if (location == null) return;
            mLastLocation = location;
            HashMap<String, String> responseMap = new HashMap<String, String>();
            Log.i(TAG, "LocationChanged: "+location);
            if(isLocationPlausible(mLastLocation)){
                plausible=true;
                Log.i("shashank","Plausible");
                ifMocked = "No";
            }
            else{
                plausible=false;
                ifMocked = "Yes";
                Log.i("shashank","Not Plausible");
            }

            Log.i("TimeFromLocation",mLastLocation.getTime()+"");
            if (String.valueOf(mLastLocation.getTime()) != null){
                currentTime= TimeUnit.MILLISECONDS.toMinutes(mLastLocation.getTime());
                if(previousTime!=0&&!timeSpoofed){
                    if((currentTime-previousTime)>10||(currentTime-previousTime)<-10){
                        timeSpoofed=true;
                        Log.i("TimeSpoofed","detected");
                    }

                }
                previousTime=currentTime;

            }

            if (String.valueOf(mLastLocation.getLatitude()) != null)
                responseMap.put("latitude", String.valueOf(mLastLocation.getLatitude()));
            if (String.valueOf(mLastLocation.getLongitude()) != null)
                responseMap.put("longitude", String.valueOf(mLastLocation.getLongitude()));
            responseMap.put("internet", "Internet Available");

            responseMap.put("mocked", ifMocked);
            responseMap.put("TimeSpoofed", timeSpoofed?"Yes":"No");

            methodChannel.invokeMethod("locationAndInternet", responseMap);

            Log.i(getClass().getSimpleName(), " Lat: " + responseMap.get("latitude") + " Longi: " + responseMap.get("longitude"));
        }

        @Override
        public void onProviderDisabled(String provider)
        {
            Log.e(TAG, "onProviderDisabled: " + provider);
        }

        @Override
        public void onProviderEnabled(String provider)
        {
            Log.e(TAG, "onProviderEnabled: " + provider);
        }

        @Override
        public void onStatusChanged(String provider, int status, Bundle extras)
        {
            Log.e(TAG, "onStatusChanged: " + status);
          //  Log.i(TAG,mLastLocation.toString());
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId)
    {
        super.onStartCommand(intent, flags, startId);
        return START_NOT_STICKY;
    }

    @Override
    public void onCreate()
    {
        Log.i("BackgroundService", "onCreate");
        startForeground(12345678, getNotification());

    }

    @Override
    public void onDestroy()
    {
        Log.i("BackgroundService", "service destroyed");
        stopForeground(true);
        super.onDestroy();
        if (mLocationManager != null) {
            try {
                mLocationManager.removeUpdates(mLocationListener);
            } catch (Exception ex) {
                Log.i("BackgroundService", "fail to remove location listners, ignore", ex);
            }
        }
    }

    private void initializeLocationManager() {
        if (mLocationManager == null) {
            mLocationManager = (LocationManager) getApplicationContext().getSystemService(Context.LOCATION_SERVICE);
        }
    }

    public void startTracking(MethodChannel methodChannel) {
        initializeLocationManager();

        mLocationListener = new LocationListener(LocationManager.GPS_PROVIDER,methodChannel);

        try {
            mLocationManager.requestLocationUpdates( LocationManager.GPS_PROVIDER, 10, 10, mLocationListener );
            mLocationManager.requestLocationUpdates( LocationManager.NETWORK_PROVIDER, 10, 10, mLocationListener );
            Location l1= mLocationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
            if(l1==null) return;
            Log.i("BackgroundService", "InitialLocation: "+l1.toString());

            Location mLastLocation = l1;
            HashMap<String, String> responseMap = new HashMap<String, String>();
            Log.i("LocationService", "initial location "+mLastLocation);
            String ifMocked;
            if(isLocationPlausible(mLastLocation)){
               // plausible=true;
                Log.i("shashank","Plausible");
                ifMocked = "No";
            }
            else{
                //plausible=false;
                ifMocked = "Yes";
                Log.i("shashank","Not Plausible");
            }

            Log.i("TimeFromLocation",mLastLocation.getTime()+"");

            if (String.valueOf(mLastLocation.getLatitude()) != null)
                responseMap.put("latitude", String.valueOf(mLastLocation.getLatitude()));
            if (String.valueOf(mLastLocation.getLongitude()) != null)
                responseMap.put("longitude", String.valueOf(mLastLocation.getLongitude()));
            responseMap.put("internet", "Internet Available");

            responseMap.put("mocked", ifMocked);
            responseMap.put("TimeSpoofed", "No");

            methodChannel.invokeMethod("locationAndInternet", responseMap);

            Log.i(getClass().getSimpleName(), " Lat: " + responseMap.get("latitude") + " Longi: " + responseMap.get("longitude"));

        } catch (SecurityException ex) {
            // Log.i(TAG, "fail to request location update, ignore", ex);
        } catch (IllegalArgumentException ex) {
            // Log.d(TAG, "gps provider does not exist " + ex.getMessage());
        }

    }

    public void stopTracking() {
        this.onDestroy();
    }

    private Notification getNotification() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel("channel_01", "My Channel", NotificationManager.IMPORTANCE_DEFAULT);

            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);

            Notification.Builder builder = new Notification.Builder(getApplicationContext(), "channel_01").setAutoCancel(true);
            return builder.build();
        }
        else {

            NotificationCompat.Builder notification = new NotificationCompat.Builder(getApplicationContext(), "simplifiedcoding")
                    .setContentTitle("Notice")
                    .setContentText("App will be idle while in background.")
                    .setSmallIcon(R.mipmap.ic_launcher);
            PendingIntent contentIntent = PendingIntent.getActivity(getApplicationContext(), 0,
                    new Intent(getApplicationContext(), MainActivity.class), PendingIntent.FLAG_UPDATE_CURRENT);
            notification.setContentIntent(contentIntent);

            /*


             */
            return notification.build();
        }
    }

    
    public class LocationServiceBinder extends Binder {
        public BackgroundLocationService getService() {
            return BackgroundLocationService.this;
        }
    }

}
