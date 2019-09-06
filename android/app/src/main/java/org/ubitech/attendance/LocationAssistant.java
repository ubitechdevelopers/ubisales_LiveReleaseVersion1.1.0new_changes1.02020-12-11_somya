package org.ubitech.attendance;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentSender;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationManager;

import java.io.IOException;
import java.net.*;
import java.util.HashMap;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;


import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.provider.Settings;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.location.LocationAvailability;
import com.google.android.gms.location.LocationListener;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResult;
import com.google.android.gms.location.LocationSettingsStatusCodes;

import io.flutter.plugin.common.MethodChannel;

/**
 * A helper class that monitors the available location info on behalf of a requesting activity or application.
 */
public class LocationAssistant
        implements GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener, LocationListener {

    /**
     * Delivers relevant events required to obtain (valid) location info.
     */
    public interface Listener {
        /**
         * Called when the user needs to grant the app location permission at run time.
         * This is only necessary on newer Android systems (API level >= 23).
         * If you want to show some explanation up front, do that, then call {@link #requestLocationPermission()}.
         * Alternatively, you can call {@link #requestAndPossiblyExplainLocationPermission()}, which will request the
         * location permission right away and invoke {@link #onExplainLocationPermission()} only if the user declines.
         * Both methods will bring up the system permission dialog.
         */
        void onNeedLocationPermission();

        /**
         * Called when the user has declined the location permission and might need a better explanation as to why
         * your app really depends on it.
         * You can show some sort of dialog or info window here and then - if the user is willing - ask again for
         * permission with {@link #requestLocationPermission()}.
         */
        void onExplainLocationPermission();

        /**
         * Called when the user has declined the location permission at least twice or has declined once and checked
         * "Don't ask again" (which will cause the system to permanently decline it).
         * You can show some sort of message that explains that the user will need to go to the app settings
         * to enable the permission. You may use the preconfigured OnClickListeners to send the user to the app
         * settings page.
         *
         * @param fromView   OnClickListener to use with a view (e.g. a button), jumps to the app settings
         * @param fromDialog OnClickListener to use with a dialog, jumps to the app settings
         */
        void onLocationPermissionPermanentlyDeclined(View.OnClickListener fromView, DialogInterface.OnClickListener fromDialog);

        /**
         * Called when a change of the location provider settings is necessary.
         * You can optionally show some informative dialog and then request the settings change with
         * {@link #changeLocationSettings()}.
         */
        void onNeedLocationSettingsChange();

        /**
         * In certain cases where the user has switched off location providers, changing the location settings from
         * within the app may not work. The LocationAssistant will attempt to detect these cases and offer a redirect to
         * the system location settings, where the user may manually enable on location providers before returning to
         * the app.
         * You can prompt the user with an appropriate message (in a view or a dialog) and use one of the provided
         * OnClickListeners to jump to the settings.
         *
         * @param fromView   OnClickListener to use with a view (e.g. a button), jumps to the location settings
         * @param fromDialog OnClickListener to use with a dialog, jumps to the location settings
         */
        void onFallBackToSystemSettings(View.OnClickListener fromView, DialogInterface.OnClickListener fromDialog);

        /**
         * Called when a new and valid location is available.
         * If you chose to reject mock locations, this method will only be called when a real location is available.
         *
         * @param location the current user location
         */
        void onNewLocationAvailable(Location location);

        /**
         * Called when the presence of mock locations was detected and {@link #allowMockLocations} is {@code false}.
         * You can use this callback to scold the user or do whatever. The user can usually disable mock locations by
         * either switching off a running mock location app (on newer Android systems) or by disabling mock location
         * apps altogether. The latter can be done in the phone's development settings. You may show an appropriate
         * message and then use one of the provided OnClickListeners to jump to those settings.
         *
         * @param fromView   OnClickListener to use with a view (e.g. a button), jumps to the development settings
         * @param fromDialog OnClickListener to use with a dialog, jumps to the development settings
         */
        void onMockLocationsDetected(View.OnClickListener fromView, DialogInterface.OnClickListener fromDialog);

        /**
         * Called when an error has occurred.
         *
         * @param type    the type of error that occurred
         * @param message a plain-text message with optional details
         */
        void onError(ErrorType type, String message);
    }

    /**
     * Possible values for the desired location accuracy.
     */
    public enum Accuracy {
        /**
         * Highest possible accuracy, typically within 30m
         */
        HIGH,
        /**
         * Medium accuracy, typically within a city block / roughly 100m
         */
        MEDIUM,
        /**
         * City-level accuracy, typically within 10km
         */
        LOW,
        /**
         * Variable accuracy, purely dependent on updates requested by other apps
         */
        PASSIVE
    }

    public enum ErrorType {
        /**
         * An error with the user's location settings
         */
        SETTINGS,
        /**
         * An error with the retrieval of location info
         */
        RETRIEVAL
    }

    private final int REQUEST_CHECK_SETTINGS = 0;
    private final int REQUEST_LOCATION_PERMISSION = 1;

    // Parameters
    protected Context context;
    private Activity activity;
    private Listener listener;
    private int priority;
    private long updateInterval;
    private boolean allowMockLocations;
    private boolean verbose;
    private boolean quiet;
    private boolean assistantStarted=false;

    // Internal state
    private boolean permissionGranted;
    private boolean cameraPermissionGranted;

    private boolean locationRequested;
    private boolean locationStatusOk;
    private boolean changeSettings;
    private boolean updatesRequested;
    protected Location bestLocation;
    private GoogleApiClient googleApiClient;
    private LocationRequest locationRequest;
    private Status locationStatus;
    private boolean mockLocationsEnabled;
    private int numTimesPermissionDeclined;
    protected int iterationCount=0,iterationCounter=0;
    // Mock location rejection
    private Location lastMockLocation;
    private int numGoodReadings;
    private MethodChannel methodChannel;
    private boolean cameraStatus=false;
    private boolean forceStart=false;
    private Context ctx;
    private long previousTime=0,currentTime=0;
    boolean timeSpoofed=false;
    /**
     * Constructs a LocationAssistant instance that will listen for valid location updates.
     *
     * @param context            the context of the application or activity that wants to receive location updates
     * @param listener           a listener that will receive location-related events
     * @param accuracy           the desired accuracy of the loation updates
     * @param updateInterval     the interval (in milliseconds) at which the activity can process updates
     * @param allowMockLocations whether or not mock locations are acceptable
     */
    public LocationAssistant(final Context context, Listener listener, Accuracy accuracy, long updateInterval,
                             boolean allowMockLocations, MethodChannel methodChannel, int iterationCount) {
        this.context = context;
        this.iterationCount=iterationCount;
        this.methodChannel=methodChannel;
        if (context instanceof Activity)
            this.activity = (Activity) context;
        this.listener = listener;
        switch (accuracy) {
            case HIGH:
                priority = LocationRequest.PRIORITY_HIGH_ACCURACY;
                break;
            case MEDIUM:
                priority = LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY;
                break;
            case LOW:
                priority = LocationRequest.PRIORITY_LOW_POWER;
                break;
            case PASSIVE:
            default:
                priority = LocationRequest.PRIORITY_NO_POWER;
        }
        this.updateInterval = updateInterval;
        this.allowMockLocations = allowMockLocations;

        // Set up the Google API client
        if (googleApiClient == null) {
            googleApiClient = new GoogleApiClient.Builder(context)
                    .addConnectionCallbacks(this)
                    .addOnConnectionFailedListener(this)
                    .addApi(LocationServices.API)
                    .build();
        }
    }

    public void updateCameraStatus(boolean cameraStatus){
        this.cameraStatus=cameraStatus;
    }
    /**
     * Makes the LocationAssistant print info log messages.
     *
     * @param verbose whether or not the LocationAssistant should print verbose log messages.
     */
    public void setVerbose(boolean verbose) {
        this.verbose = verbose;
    }

    /**
     * Mutes/unmutes all log output.
     * You may want to mute the LocationAssistant in production.
     *
     * @param quiet whether or not to disable all log output (including errors).
     */
    public void setQuiet(boolean quiet) {
        this.quiet = quiet;
    }

    /**
     * Starts the LocationAssistant and makes it subscribe to valid location updates.
     * Call this method when your application or activity becomes awake.
     */
    public void start() {

        Log.i("shashank","Start Location Assistant. Assistant Started:"+assistantStarted+"   Force Start:"+forceStart);

        if(!assistantStarted||forceStart){
            Log.i("shashank","inside condition google api client"+googleApiClient.toString());

            if(forceStart){
                if (googleApiClient.isConnected()) {
                    LocationServices.FusedLocationApi.removeLocationUpdates(googleApiClient, this);
                    googleApiClient.disconnect();
                }
                permissionGranted = false;
                locationRequested = false;
                locationStatusOk = false;
                updatesRequested = false;
                assistantStarted=false;
                timeSpoofed=false;

            }

           try{
               iterationCounter=0;
               checkMockLocations();
               googleApiClient.connect();
               assistantStarted=true;
               forceStart=false;

           }catch (Exception e){
               Log.i("shashank","error connecting to client");
           }


        }

    }


    public void forceStart(){


            Log.i("shashank","Force Start Location Assistant. Assistant Started:"+assistantStarted);
            forceStart=true;

             start();


    }

    /**
     * Updates the active Activity for which the LocationAssistant manages location updates.
     * When you want the LocationAssistant to start and stop with your overall application, but service different
     * activities, call this method at the end of your  implementation.
     *
     * @param activity the activity that wants to receive location updates
     * @param listener a listener that will receive location-related events
     */
    public void register(Activity activity, Listener listener) {
        this.activity = activity;
        this.listener = listener;
        checkInitialLocation();
        acquireLocation();
    }

    /**
     * Stops the LocationAssistant and makes it unsubscribe from any location updates.
     * Call this method right before your application or activity goes to sleep.
     */
    public void stop() {
        if(assistantStarted){
            iterationCounter=0;
            if (googleApiClient.isConnected()) {
                LocationServices.FusedLocationApi.removeLocationUpdates(googleApiClient, this);
                googleApiClient.disconnect();
            }
            permissionGranted = false;
            locationRequested = false;
            locationStatusOk = false;
            updatesRequested = false;
            assistantStarted=false;
        }

    }

    /**
     * Clears the active Activity and its listener.
     * Until you register a new activity and listener, the LocationAssistant will silently produce error messages.
     * When you want the LocationAssistant to start and stop with your overall application, but service different
     * activities, call this method at the beginning of your implementation.
     */
    public void unregister() {
        this.activity = null;
        this.listener = null;
    }

    /**
     * In rare cases (e.g. after losing connectivity) you may want to reset the LocationAssistant and have it start
     * from scratch. Use this method to do so.
     */
    public void reset() {
        permissionGranted = false;
        locationRequested = false;
        locationStatusOk = false;
        updatesRequested = false;
        acquireLocation();
    }

    /**
     * Returns the best valid location currently available.
     * Usually, this will be the last valid location that was received.
     *
     * @return the best valid location
     */
    public Location getBestLocation() {
        return bestLocation;
    }

    /**
     * The first time you call this method, it brings up a system dialog asking the user to give location permission to
     * the app. On subsequent calls, if the user has previously declined permission, this method invokes
     * {@link Listener#onExplainLocationPermission()}.
     */
    public void requestAndPossiblyExplainLocationPermission() {
        if (permissionGranted) return;
        if (activity == null) {
            if (!quiet){
                Log.i(getClass().getSimpleName(), "Need location permission, but no activity is registered! " +
                        "Specify a valid activity when constructing " + getClass().getSimpleName() +
                        " or register it explicitly with register().");

                stop();
            }

            return;
        }
        if (ActivityCompat.shouldShowRequestPermissionRationale(activity, Manifest.permission.ACCESS_FINE_LOCATION)
                && listener != null)
            listener.onExplainLocationPermission();
        else
            requestLocationPermission();
        requestCameraPermission();
    }

    /**
     * Brings up a system dialog asking the user to give location permission to the app.
     */
    public void requestLocationPermission() {
        if (activity == null) {
            if (!quiet){
                stop();
                Log.i(getClass().getSimpleName(), "Need location permission, but no activity is registered! " +
                        "Specify a valid activity when constructing " + getClass().getSimpleName() +
                        " or register it explicitly with register().");

            }
                  return;
        }
        ActivityCompat.requestPermissions(activity,
                new String[]{Manifest.permission.CAMERA,Manifest.permission.ACCESS_FINE_LOCATION,Manifest.permission.WRITE_EXTERNAL_STORAGE}, REQUEST_LOCATION_PERMISSION);

    }
    public void requestCameraPermission() {

        ActivityCompat.requestPermissions(activity,
                new String[]{Manifest.permission.CAMERA}, 1);

    }
    /**
     * Call this method at the end of your {@link Activity#onRequestPermissionsResult} implementation to notify the
     * LocationAssistant of an update in permissions.
     *
     * @param requestCode  the request code returned to the activity (simply pass it on)
     * @param grantResults the results array returned to the activity (simply pass it on)
     * @return {@code true} if the location permission was granted, {@code false} otherwise
     */
    public boolean onPermissionsUpdated(int requestCode, int[] grantResults) {

        if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            acquireLocation();

        }
        return true;
    }

    /**
     * Call this method at the end of your  implementation to notify the
     * LocationAssistant of a change in location provider settings.
     *
     * @param requestCode the request code returned to the activity (simply pass it on)
     * @param resultCode  the result code returned to the activity (simply pass it on)
     */
    public void onActivityResult(int requestCode, int resultCode) {
        if (requestCode != REQUEST_CHECK_SETTINGS) return;
        if (resultCode == Activity.RESULT_OK) {
            changeSettings = false;
            locationStatusOk = true;
        }
        acquireLocation();
    }

    /**
     * Brings up an in-app system dialog that requests a change in location provider settings.
     * The settings change may involve switching on GPS and/or network providers and depends on the accuracy and
     * update interval that was requested when constructing the LocationAssistant.
     * Call this method only from within {@link Listener#onNeedLocationSettingsChange()}.
     */
    public void changeLocationSettings() {
        if (locationStatus == null) return;
        if (activity == null) {
            if (!quiet){
                stop();
                Log.i(getClass().getSimpleName(), "Need to resolve location status issues, but no activity is " +
                        "registered! Specify a valid activity when constructing " + getClass().getSimpleName() +
                        " or register it explicitly with register().");

            }
                   return;
        }
        try {
            locationStatus.startResolutionForResult(activity, REQUEST_CHECK_SETTINGS);
        } catch (IntentSender.SendIntentException e) {
            if (!quiet)
            {
                stop();
                Log.i(getClass().getSimpleName(), "Error while attempting to resolve location status issues:\n" +
                        e.toString());
            }

            if (listener != null){
                listener.onError(ErrorType.SETTINGS, "Could not resolve location settings issue:\n" +
                        e.getMessage());
                stop();
            }

            changeSettings = false;
            acquireLocation();
        }
    }

    protected void acquireLocation() {
        Log.i("shashank","permission granted"+permissionGranted+" Location Requested"+locationRequested+" locationStatusOk"+locationStatusOk+" updatesRequested"+updatesRequested+" checkLocationAvailability()"+checkLocationAvailability());
        if (!permissionGranted) checkLocationPermission();
        if (!permissionGranted) {
            if (numTimesPermissionDeclined >= 2) return;
            if (listener != null)
                listener.onNeedLocationPermission();
            else if (!quiet){
                stop();
                Log.i(getClass().getSimpleName(), "Need location permission, but no listener is registered! " +
                        "Specify a valid listener when constructing " + getClass().getSimpleName() +
                        " or register it explicitly with register().");
            }

            return;
        }
        if (!locationRequested) {
            requestLocation();
            return;
        }
        if (!locationStatusOk) {
            if (changeSettings) {
                if (listener != null)
                    listener.onNeedLocationSettingsChange();
                else if (!quiet){
                    stop();
                    Log.e(getClass().getSimpleName(), "Need location settings change, but no listener is " +
                            "registered! Specify a valid listener when constructing " + getClass().getSimpleName() +
                            " or register it explicitly with register().");
                }

            } else
                checkProviders();
            return;
        }
        if (!updatesRequested) {
            requestLocationUpdates();
            // Check back in a few
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    acquireLocation();
                }
            }, 10000);
            return;
        }

        if (!checkLocationAvailability()) {
            // Something is wrong - probably the providers are disabled.
            checkProviders();
        }
    }



    protected void checkInitialLocation() {
        if (!googleApiClient.isConnected() || !permissionGranted || !locationRequested || !locationStatusOk) return;
        try {
            Log.i("shashank","check initial location");
            Location location = LocationServices.FusedLocationApi.getLastLocation(googleApiClient);
            onLocationChanged(location);
        } catch (SecurityException e) {
            if (!quiet)
            {
                stop();
                Log.i(getClass().getSimpleName(), "Error while requesting last location:\n " +
                        e.toString());
            }

            if (listener != null)
                listener.onError(ErrorType.RETRIEVAL, "Could not retrieve initial location:\n" +
                        e.getMessage());
        }
        catch (Exception e){
            e.printStackTrace();
        }
    }




    private void checkMockLocations() {
        // Starting with API level >= 18 we can (partially) rely on .isFromMockProvider()
        // (http://developer.android.com/reference/android/location/Location.html#isFromMockProvider%28%29)
        // For API level < 18 we have to check the Settings.Secure flag
       //checkInternet();
        if (Build.VERSION.SDK_INT < 18 &&
                !Settings.Secure.getString(context.getContentResolver(), Settings
                        .Secure.ALLOW_MOCK_LOCATION).equals("0")) {
            mockLocationsEnabled = true;
            if (listener != null)
                listener.onMockLocationsDetected(onGoToDevSettingsFromView, onGoToDevSettingsFromDialog);
        } else
            mockLocationsEnabled = false;

        Log.i("shashank","checking Mock Location "+mockLocationsEnabled);
    }

    private void checkLocationPermission() {
        permissionGranted = Build.VERSION.SDK_INT < 23 ||
                ContextCompat.checkSelfPermission(context,
                        Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED;
    }

    private void requestLocation() {
        if (!googleApiClient.isConnected() || !permissionGranted) return;
        Log.i("shashank","googleApiClient.isConnected() || !permissionGranted"+!googleApiClient.isConnected() +" || "+!permissionGranted);

        locationRequest = LocationRequest.create();
        locationRequest.setPriority(priority);
        locationRequest.setInterval(updateInterval);
        locationRequest.setFastestInterval(updateInterval);
        LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder()
                .addLocationRequest(locationRequest);
        builder.setAlwaysShow(true);
        LocationServices.SettingsApi.checkLocationSettings(googleApiClient, builder.build())
                .setResultCallback(onLocationSettingsReceived);
    }

    private boolean checkLocationAvailability() {
        if (!googleApiClient.isConnected() || !permissionGranted) return false;
        try {
            LocationAvailability la = LocationServices.FusedLocationApi.getLocationAvailability(googleApiClient);
            return (la != null && la.isLocationAvailable());
        } catch (SecurityException e) {
            if (!quiet){
                stop();
                Log.i(getClass().getSimpleName(), "Error while checking location availability:\n " + e.toString());
            }

            if (listener != null)
                listener.onError(ErrorType.RETRIEVAL, "Could not check location availability:\n" +
                        e.getMessage());
            return false;
        }
    }

    private void checkProviders() {
        // Do it the old fashioned way
        LocationManager locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
        boolean gps = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
        boolean network = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
        if (gps || network) return;
        if (listener != null)
            listener.onFallBackToSystemSettings(onGoToLocationSettingsFromView, onGoToLocationSettingsFromDialog);
        else if (!quiet){
            stop();
            Log.i(getClass().getSimpleName(), "Location providers need to be enabled, but no listener is " +
                    "registered! Specify a valid listener when constructing " + getClass().getSimpleName() +
                    " or register it explicitly with register().");
        }

    }

    private void requestLocationUpdates() {
        if (!googleApiClient.isConnected() || !permissionGranted || !locationRequested) return;
        try {
            LocationServices.FusedLocationApi.requestLocationUpdates(googleApiClient, locationRequest, this);
            updatesRequested = true;
        } catch (SecurityException e) {
            if (!quiet){
                stop();
                Log.i(getClass().getSimpleName(), "Error while requesting location updates:\n " +
                        e.toString());
            }

            if (listener != null)
                listener.onError(ErrorType.RETRIEVAL, "Could not request location updates:\n" +
                        e.getMessage());
        }
    }

    private DialogInterface.OnClickListener onGoToLocationSettingsFromDialog = new DialogInterface.OnClickListener() {
        @Override
        public void onClick(DialogInterface dialog, int which) {
            if (activity != null) {
                Intent intent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
                activity.startActivity(intent);
            } else if (!quiet){
                stop();
                Log.i(getClass().getSimpleName(), "Need to launch an intent, but no activity is registered! " +
                        "Specify a valid activity when constructing " + getClass().getSimpleName() +
                        " or register it explicitly with register().");
            }

        }
    };

    private View.OnClickListener onGoToLocationSettingsFromView = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            if (activity != null) {
                Intent intent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
                activity.startActivity(intent);
            } else if (!quiet){
                stop();
                Log.i(getClass().getSimpleName(), "Need to launch an intent, but no activity is registered! " +
                        "Specify a valid activity when constructing " + getClass().getSimpleName() +
                        " or register it explicitly with register().");
            }

        }
    };

    private DialogInterface.OnClickListener onGoToDevSettingsFromDialog = new DialogInterface.OnClickListener() {
        @Override
        public void onClick(DialogInterface dialog, int which) {
            if (activity != null) {
                Intent intent = new Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS);
                activity.startActivity(intent);
            } else if (!quiet){
                stop();
                Log.i(getClass().getSimpleName(), "Need to launch an intent, but no activity is registered! " +
                        "Specify a valid activity when constructing " + getClass().getSimpleName() +
                        " or register it explicitly with register().");
            }

        }
    };

    private View.OnClickListener onGoToDevSettingsFromView = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            if (activity != null) {
                Intent intent = new Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS);
                activity.startActivity(intent);
            } else if (!quiet){
                stop();
                Log.i(getClass().getSimpleName(), "Need to launch an intent, but no activity is registered! " +
                        "Specify a valid activity when constructing " + getClass().getSimpleName() +
                        " or register it explicitly with register().");
            }

        }
    };

    private DialogInterface.OnClickListener onGoToAppSettingsFromDialog = new DialogInterface.OnClickListener() {
        @Override
        public void onClick(DialogInterface dialog, int which) {
            if (activity != null) {
                Intent intent = new Intent();
                intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                Uri uri = Uri.fromParts("package", activity.getPackageName(), null);
                intent.setData(uri);
                activity.startActivity(intent);
            } else if (!quiet){
                stop();
                Log.e(getClass().getSimpleName(), "Need to launch an intent, but no activity is registered! " +
                        "Specify a valid activity when constructing " + getClass().getSimpleName() +
                        " or register it explicitly with register().");
            }

        }
    };

    private View.OnClickListener onGoToAppSettingsFromView = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            if (activity != null) {
                Intent intent = new Intent();
                intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                Uri uri = Uri.fromParts("package", activity.getPackageName(), null);
                intent.setData(uri);
                activity.startActivity(intent);
            } else if (!quiet){
                stop();
                Log.e(getClass().getSimpleName(), "Need to launch an intent, but no activity is registered! " +
                        "Specify a valid activity when constructing " + getClass().getSimpleName() +
                        " or register it explicitly with register().");
            }

        }
    };

    private boolean isLocationPlausible(Location location) {
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

    @Override
    public void onConnected(@Nullable Bundle bundle) {
        Log.i("shashank"," google api client connected");
        acquireLocation();
    }

    @Override
    public void onConnectionSuspended(int i) {
        Log.i("shashank"," google api client onConnectionSuspended");
    }

    @Override
    public void onLocationChanged(Location location) {

//        checkInternet();
        Log.i("shashank","iteration count inside location changed"+iterationCounter);
        if (location == null) return;
        iterationCounter++;
        if(iterationCounter>iterationCount)
        {

            stop();
        }
try {
    bestLocation = location;

    HashMap<String, String> responseMap = new HashMap<String, String>();

    boolean plausible = isLocationPlausible(location);
    try {


        // Add keys and values (Country, City)
        Log.i("TimeFromLocation",bestLocation.getTime()+"");
        if (String.valueOf(bestLocation.getTime()) != null){
            currentTime= TimeUnit.MILLISECONDS.toMinutes(bestLocation.getTime());
            if(previousTime!=0&&!timeSpoofed){
                if((currentTime-previousTime)>10||(currentTime-previousTime)<-10){
                    timeSpoofed=true;
                    Log.i("TimeSpoofed","detected");
                }

            }
            previousTime=currentTime;

        }

        if (String.valueOf(bestLocation.getLatitude()) != null)
            responseMap.put("latitude", String.valueOf(bestLocation.getLatitude()));
        if (String.valueOf(bestLocation.getLongitude()) != null)
            responseMap.put("longitude", String.valueOf(bestLocation.getLongitude()));
        CheckInternet c = new CheckInternet(methodChannel);
        String internet = c.execute("").get();
        responseMap.put("internet", internet);
        String ifMocked = "";
        if (plausible) {
            ifMocked = "No";
        } else {
            ifMocked = "Yes";
        }
        responseMap.put("mocked", ifMocked);
        responseMap.put("TimeSpoofed", timeSpoofed?"Yes":"No");


        methodChannel.invokeMethod("locationAndInternet", responseMap);


        Log.i(getClass().getSimpleName(), " Lat: " + responseMap.get("latitude") + " Longi: " + responseMap.get("longitude"));

    } catch (Exception e) {
        e.printStackTrace();
    }
    if (location == null) return;
     plausible = isLocationPlausible(location);
    if (verbose && !quiet){
        Log.i(getClass().getSimpleName(), location.toString() +
                (plausible ? " -> plausible" : " -> not plausible"));

    }

    if (!allowMockLocations && !plausible) {
        if (listener != null) listener.onMockLocationsDetected(onGoToDevSettingsFromView,
                onGoToDevSettingsFromDialog);
        return;
    }

    bestLocation = location;
    if (listener != null)
        listener.onNewLocationAvailable(location);
    else if (!quiet){
        stop();
        Log.w(getClass().getSimpleName(), "New location is available, but no listener is registered!\n" +
                "Specify a valid listener when constructing " + getClass().getSimpleName() +
                " or register it explicitly with register().");
    }

}
catch(Exception e){
    e.printStackTrace();
}

    }

    @Override
    public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {
        Log.i("shashank","onConnectionFailed");
        if (!quiet){
            stop();
            Log.i(getClass().getSimpleName(), "Error while trying to connect to Google API:\n" +
                    connectionResult.getErrorMessage());
        }

        if (listener != null)
            listener.onError(ErrorType.RETRIEVAL, "Could not connect to Google API:\n" +
                    connectionResult.getErrorMessage());
    }

    ResultCallback<LocationSettingsResult> onLocationSettingsReceived = new ResultCallback<LocationSettingsResult>() {
        @Override
        public void onResult(@NonNull LocationSettingsResult result) {
            locationRequested = true;
            locationStatus = result.getStatus();
            switch (locationStatus.getStatusCode()) {
                case LocationSettingsStatusCodes.SUCCESS:
                    locationStatusOk = true;
                    checkInitialLocation();
                    break;
                case LocationSettingsStatusCodes.RESOLUTION_REQUIRED:
                    locationStatusOk = false;
                    changeSettings = true;
                    break;
                case LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE:
                    locationStatusOk = false;
                    break;
            }
            acquireLocation();
        }
    };

}