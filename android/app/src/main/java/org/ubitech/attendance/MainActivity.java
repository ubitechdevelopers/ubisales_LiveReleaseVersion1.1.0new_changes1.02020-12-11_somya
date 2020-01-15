package org.ubitech.attendance;

import android.Manifest;
import android.app.Activity;
import android.app.ActivityManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentSender;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.location.Location;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.StrictMode;
import android.provider.Settings;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.work.ExistingWorkPolicy;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;

import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.ResolvableApiException;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResponse;
import com.google.android.gms.location.LocationSettingsStatusCodes;
import com.google.android.gms.location.SettingsClient;
import com.google.android.gms.tasks.OnCanceledListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Timer;
import java.util.concurrent.TimeUnit;

import io.flutter.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;
public class MainActivity extends FlutterActivity implements LocationAssistant.Listener{

  private LocationAssistant assistant;
  private static final String CHANNEL = "location.spoofing.check";
  private static final String CAMERA_CHANNEL = "update.camera.status";
  private static final String FACEBOOK_CHANNEL = "log.facebook.data";
  private boolean cameraOpened=false;
  private BackgroundLocationService gpsService;


  private SettingsClient mSettingsClient;
  private LocationSettingsRequest mLocationSettingsRequest;
  private static final int REQUEST_CHECK_SETTINGS = 214;
  private static final int REQUEST_ENABLE_GPS = 516;


  MethodChannel channel;
  //LocationListenerExecuter listenerExecuter;
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Log.i("Dialog","hdghdgjdgjdgdjgdjgdjggggggg");

    Intent i=getIntent();
      final Handler handler = new Handler();
      handler.postDelayed(new Runnable() {
          @Override
          public void run() {
              onNewIntent(i);
          }
      }, 7000);

    //onNewIntent(i);


  //showLocationDialog();
   // FacebookEventLoggers facebookLogger=new FacebookEventLoggers(getApplicationContext());
/*
      Intent intent1 = new Intent();

      String manufacturer = android.os.Build.MANUFACTURER;

      switch (manufacturer) {

          case "xiaomi":
              intent1.setComponent(new ComponentName("com.miui.securitycenter",
                      "com.miui.permcenter.autostart.AutoStartManagementActivity"));
              break;
          case "oppo":
              intent1.setComponent(new ComponentName("com.coloros.safecenter",
                      "com.coloros.safecenter.permission.startup.StartupAppListActivity"));

              break;
          case "vivo":
              intent1.setComponent(new ComponentName("com.vivo.permissionmanager",
                      "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"));
              break;
      }

      List<ResolveInfo> arrayList =  getPackageManager().queryIntentActivities(intent1,
              PackageManager.MATCH_DEFAULT_ONLY);

      if (arrayList.size() > 0) {
          startActivity(intent1);
      }
*/


      Intent intent111 = new Intent(getApplicationContext(), MainActivity.class);
      intent111.setAction(Intent.ACTION_RUN);
      intent111.putExtra("route", "settings");
      intent111.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      getApplicationContext().startActivity(intent111);



    MethodChannel facebookChannel=new MethodChannel(getFlutterView(), FACEBOOK_CHANNEL);

    //facebookLogger.logCompleteRegistrationEvent("");
    //facebookLogger.logContactEvent();
    //facebookLogger.logPurchaseEvent();
    //facebookLogger.logRateEvent("","","0",5,4);
    //facebookLogger.logStartTrialEvent("","",0.0);
    facebookChannel.setMethodCallHandler(
            new MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, Result result) {
                if (call.method.equals("logCompleteRegistrationEvent")) {
                 // if(facebookLogger!=null);
                 // facebookLogger.logCompleteRegistrationEvent("");
                }
                else
                if (call.method.equals("logContactEvent")) {
                 // if(facebookLogger!=null);
                 // facebookLogger.logContactEvent();
                }
                else
                if (call.method.equals("logPurchaseEvent")) {
                 // if(facebookLogger!=null);
                // facebookLogger.logPurchaseEvent();
                }
                if (call.method.equals("logRateEvent")) {
                  // Log.i("Assistant","Assistant Start Called");
                 // if(facebookLogger!=null);
                 // facebookLogger.logRateEvent("","","0",5,4);
                }
                if (call.method.equals("logStartTrialEvent")) {
                 // if(facebookLogger!=null);
                // facebookLogger.logStartTrialEvent("","",0.0);

                }

              }
            });


    if (android.os.Build.VERSION.SDK_INT > 9)
    {
      StrictMode.ThreadPolicy policy = new
              StrictMode.ThreadPolicy.Builder().permitAll().build();
      StrictMode.setThreadPolicy(policy);
    }
      ActivityCompat.requestPermissions(this,
             new String[]{Manifest.permission.CAMERA,Manifest.permission.ACCESS_FINE_LOCATION,Manifest.permission.WRITE_EXTERNAL_STORAGE,Manifest.permission.READ_CONTACTS}, 1);

    channel=new MethodChannel(getFlutterView(), CHANNEL);
    GeneratedPluginRegistrant.registerWith(this);

    try{
        final Intent intent = new Intent(this.getApplication(), BackgroundLocationService.class);
        this.getApplication().startService(intent);

        //this.getApplication().startForegroundService(intent);

     this.getApplication().bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);


    }
    catch(Exception e){
        Log.e("AsyncTask",e.getMessage());
    }
      Timer timer = new Timer();

      new MethodChannel(getFlutterView(), CAMERA_CHANNEL).setMethodCallHandler(
            new MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, Result result) {
                if (call.method.equals("cameraOpened")) {
                  cameraOpened=true;
                  Log.i("camera","camera opened true");
                  try{
                      /*
                  if(listenerExecuter!=null)
                 listenerExecuter.updateCameraStatus(true);
                  */
                  }

                  catch(Exception e){

                  }
                }
                else
                if (call.method.equals("cameraClosed")) {
                    Log.i("camera","camera opened false");
                    cameraOpened=false;
                    try{
                      /*
                  if(listenerExecuter!=null)
                  listenerExecuter.updateCameraStatus(false);

                       */
                    }
                    catch(Exception e){

                    }
                }
                else
                if (call.method.equals("askAudioPermission")) {
                    Log.i("audio","permission asked");
                    try{

                        ActivityCompat.requestPermissions(MainActivity.this,
                                new String[]{Manifest.permission.RECORD_AUDIO}, 444);



                      /*
                  if(listenerExecuter!=null)
                  listenerExecuter.updateCameraStatus(false);

                       */
                    }
                    catch(Exception e){

                    }
                }
                else
                if (call.method.equals("startAssistant")) {
                  Log.i("Assistant","Assistant Start Called");

                  manuallyStartAssistant();
                }else
                if (call.method.equals("startTimeOutNotificationWorker")) {
                  // Log.i("Assistant","Assistant Start Called");
                 // WorkManager.getInstance().cancelAllWorkByTag("TimeInWork");// Cancel time in work if scheduled previously
                  //String ShiftTimeOut = call.argument("ShiftTimeOut");
                  //Log.i("ShiftTimeout",ShiftTimeOut);
                  //startTimeOutNotificationWorker(ShiftTimeOut);
                }else
                if (call.method.equals("startTimeInNotificationWorker")) {
                  // Log.i("Assistant","Assistant Start Called");
                  //WorkManager.getInstance().cancelAllWorkByTag("TimeOutWork");// Cancel time out work if scheduled previously
                 // String ShiftTimeIn = call.argument("ShiftTimeIn");
                   // String nextWorkingDay = call.argument("nextWorkingDay");
                 // Log.i("nextWorkingDay",nextWorkingDay);
                 // startTimeInNotificationWorker(ShiftTimeIn,nextWorkingDay);
                }else
                if (call.method.equals("openLocationDialog")) {
                  openLocationDialog();
                }
                else if (call.method.equals("showNotification")) {

                    String notiTitle = call.argument("title");
                    String notiDescription = call.argument("description");
                    String pageToOpenOnClick = call.argument("pageToOpenOnClick");

                    DisplayNotification displayNotification=new DisplayNotification(getApplicationContext());

                    displayNotification.displayNotification(notiTitle,notiDescription,pageToOpenOnClick);
                }

              }
            });



  }
    public static boolean isServiceRunningInForeground(Context context, Class<?> serviceClass) {
        ActivityManager manager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
            if (serviceClass.getName().equals(service.service.getClassName())) {
                if (service.foreground) {
                    return true;
                }

            }
        }
        return false;
    }
    private ServiceConnection serviceConnection = new ServiceConnection() {
        public void onServiceConnected(ComponentName className, IBinder service) {
            String name = className.getClassName();
            Log.i("abc","serviceConnected "+name);
            if (name.endsWith("BackgroundLocationService")) {
                gpsService = ((BackgroundLocationService.LocationServiceBinder) service).getService();

                    gpsService.startTracking(channel);


            }
        }

        public void onServiceDisconnected(ComponentName className) {
            if (className.getClassName().equals("BackgroundLocationService")) {
                gpsService = null;
            }
        }
    };

    public static void triggerRebirth(Context context) {
        PackageManager packageManager = context.getPackageManager();
        Intent intent = packageManager.getLaunchIntentForPackage(context.getPackageName());
        ComponentName componentName = intent.getComponent();
        Intent mainIntent = Intent.makeRestartActivityTask(componentName);
        context.startActivity(mainIntent);
        Runtime.getRuntime().exit(0);
    }


  public void openLocationDialog(){


    LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder();
    builder.addLocationRequest(new LocationRequest().setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY));
    builder.setAlwaysShow(true);
    mLocationSettingsRequest = builder.build();

    mSettingsClient = LocationServices.getSettingsClient(MainActivity.this);

    mSettingsClient
            .checkLocationSettings(mLocationSettingsRequest)
            .addOnSuccessListener(new OnSuccessListener<LocationSettingsResponse>() {
              @Override
              public void onSuccess(LocationSettingsResponse locationSettingsResponse) {
                //Success Perform Task Here
              }
            })
            .addOnFailureListener(new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception e) {
                int statusCode = ((ApiException) e).getStatusCode();
                switch (statusCode) {
                  case LocationSettingsStatusCodes.RESOLUTION_REQUIRED:
                    try {
                      ResolvableApiException rae = (ResolvableApiException) e;
                      rae.startResolutionForResult(MainActivity.this, REQUEST_CHECK_SETTINGS);
                    } catch (IntentSender.SendIntentException sie) {
                      Log.e("GPS","Unable to execute request.");
                    }
                    break;
                  case LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE:
                    Log.e("GPS","Location settings are inadequate, and cannot be fixed here. Fix in Settings.");
                }
              }
            })
            .addOnCanceledListener(new OnCanceledListener() {
              @Override
              public void onCanceled() {
                Log.e("GPS","checkLocationSettings -> onCanceled");
              }
            });



  }

  @Override
  public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
    super.onActivityResult(requestCode, resultCode, data);

    if (requestCode == REQUEST_CHECK_SETTINGS) {
      switch (resultCode) {
        case Activity.RESULT_OK:
          //Success Perform Task Here
          manuallyStartAssistant();
          break;
        case Activity.RESULT_CANCELED:
          Log.e("GPS","User denied to access location");
          openLocationDialog();
          break;
      }
    } else if (requestCode == REQUEST_ENABLE_GPS) {
      LocationManager locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
      boolean isGpsEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);

      if (!isGpsEnabled) {
        openLocationDialog();
      } else {

        //navigateToUser();
       // manuallyStartAssistant();
      }
    }
    else if(requestCode==444){
    /*    Log.i("request code",""+requestCode);
        triggerRebirth(MainActivity.this);
*/
    }
  }

  private void openGpsEnableSetting() {
    Intent intent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
    startActivityForResult(intent, REQUEST_ENABLE_GPS);
  }



  public void startTimeOutNotificationWorker(String ShiftTimeOut){
    Calendar cal = Calendar.getInstance();
    SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
    String currentTime=sdf.format(cal.getTime());
    Log.i("DateShashank",currentTime+"");

    SimpleDateFormat format = new SimpleDateFormat("HH:mm:ss");
    Date date1 = null,date2=null;
    long minutes=0;
    try {
      date1 = format.parse(ShiftTimeOut);
      date2 = format.parse(currentTime);
      long differenceinMilli = date1.getTime()- date2.getTime();
      minutes = TimeUnit.MILLISECONDS.toMinutes(differenceinMilli);
      Log.i("differenceinMilli",differenceinMilli+"");
      Log.i("minutes",minutes+"");
      if(minutes<0){
        minutes=0;
      }
      else{
        minutes=minutes+5;
      }
    } catch (ParseException e) {
      Log.i("TimeError","Time not correct when calculating worker interval");
      e.printStackTrace();
    }


Log.i("WorkerMinutesForTimeOut",minutes+"");
  final OneTimeWorkRequest workRequest = new OneTimeWorkRequest.Builder(TimeOutNotificationWork.class)
          .setInitialDelay(minutes, TimeUnit.MINUTES)
          .addTag("TimeOutWork")
          .build();
  WorkManager.getInstance().enqueue(workRequest);
}


  public void startTimeInNotificationWorker(String ShiftTimeIn,String nextWorkingDay){
    Calendar cal = Calendar.getInstance();
    Log.i("nextWorkingday",nextWorkingDay);
      String dateStart = nextWorkingDay+" "+ShiftTimeIn;
      String dateStop = "01/15/2012 10:31:48";

      //HH converts hour in 24 hours format (0-23), day calculation
      SimpleDateFormat format = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");

      Date d1 = null;
      Date d2 = null;
      long diffMinutes=0;
      try {
          d1 = format.parse(dateStart);
          d2 =  new Date(System.currentTimeMillis());

          //in milliseconds
          long diff =  d1.getTime()-d2.getTime() ;
           Log.i("diff",diff+"");
          long diffSeconds = diff / 1000 % 60;
          diffMinutes = diff / (60 * 1000) % 60;
          long diffHours = diff / (60 * 60 * 1000) % 24;
          long diffDays = diff / (24 * 60 * 60 * 1000);
         diffMinutes = diffMinutes+diffDays*1440+diffHours*60;
          if(diffMinutes<0){
            diffMinutes=0;
          }
          else{
            diffMinutes=diffMinutes+5;
          }

      } catch (Exception e) {
          e.printStackTrace();
      }














    Log.i("WorkerMinutesForTimeIn",diffMinutes+"");
    final OneTimeWorkRequest workRequest = new OneTimeWorkRequest.Builder(TimeInNotificationWork.class)
            .setInitialDelay(diffMinutes, TimeUnit.MINUTES)
            .addTag("TimeInWork")
            .build()
            ;



      WorkManager w=WorkManager.getInstance();
      w.enqueueUniqueWork("TimeInNotificationWork", ExistingWorkPolicy.KEEP,workRequest);

  }


  public void manuallyStartAssistant(){
    try{
        if(gpsService!=null&&channel!=null)
       // if(!listenerExecuter.isCancelled())
            gpsService.startTracking(channel);
    }
    catch(Exception e){

    }
  }
  @Override
  public void onMockLocationsDetected(View.OnClickListener fromView, DialogInterface.OnClickListener fromDialog) {
    //  tvLocation.setText(getString(R.string.mockLocationMessage));
    //  tvLocation.setOnClickListener(fromView);
   // channel.invokeMethod("message", "Location is mocked");
  }
  @Override
  public void onDestroy() {
    try{
    if(gpsService!=null)
    gpsService.stopTracking();
    }
    catch(Exception e){

    }
    super.onDestroy();

  }
  @Override
  protected void onResume() {
    super.onResume();
    if(gpsService!=null)
    Log.i("serviceRunning", String.valueOf(isServiceRunningInForeground(getApplicationContext(),gpsService.getClass() )));
    try{
   if(!cameraOpened)
       startService(new Intent(this,BackgroundLocationService.class));
     if(gpsService!=null&&channel!=null){
         gpsService.startTracking(channel);
     }

    }
    catch(Exception e){

    }
     // assistant.start();
  }

  @Override
  protected void onPause() {
   // assistant.stop();
  //if(!cameraOpened)
    try {
      if (gpsService != null)
      {
          stopService(new Intent(this,BackgroundLocationService.class));

      }

    }
    catch(Exception e){

    }
    super.onPause();
  }





  @Override
  public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    if(permissions!=null&&permissions.length>0) {
      for (int i = 0; i < permissions.length; i++) {

try{
        if (permissions[i].equals(Manifest.permission.ACCESS_FINE_LOCATION)&&gpsService!=null) {
          Log.i("Peeeerrrr", requestCode + "detected");
          manuallyStartAssistant(); ;

        }
}
catch(Exception e){

}

      }
    }

  // Log.i("Perrrrr",permissions[1]+grantResults);

  }
/*
  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    assistant.onActivityResult(requestCode, resultCode);
  }
*/
  @Override
  public void onNeedLocationPermission() {
    //    tvLocation.setText("Need\nPermission");
    /*    tvLocation.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                assistant.requestLocationPermission();
        });*/
 try{
     /*
    if(listenerExecuter!=null)
   listenerExecuter.requestLocationPermission();
    if(listenerExecuter!=null)
    listenerExecuter.requestAndPossiblyExplainLocationPermission();
      */
 }
 catch(Exception e){

 }
  }

  @Override
  public void onExplainLocationPermission() {
/*
    new AlertDialog.Builder(this)
            .setMessage(R.string.permissionExplanation)
            .setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
              @Override
              public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                assistant.requestLocationPermission();
              }
            })
            .setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
              @Override
              public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                       /* tvLocation.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                assistant.requestLocationPermission();
                            }
                        });*/
             /* }
            })
            .show();*/
  }

  @Override
  public void onLocationPermissionPermanentlyDeclined(View.OnClickListener fromView,
                                                      DialogInterface.OnClickListener fromDialog) {
   /* new AlertDialog.Builder(this)
            .setMessage(R.string.permissionPermanentlyDeclined)
            .setPositiveButton(R.string.ok, fromDialog)
            .show();*/
  }

  @Override
  public void onNeedLocationSettingsChange() {
    /*
    new AlertDialog.Builder(this)
            .setMessage(R.string.switchOnLocationShort)
            .setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
              @Override
              public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                assistant.changeLocationSettings();
              }
            })
            .show();
            */
  }

  @Override
  public void onFallBackToSystemSettings(View.OnClickListener fromView, DialogInterface.OnClickListener fromDialog) {
    /*
    new AlertDialog.Builder(this)
            .setMessage(R.string.switchOnLocationLong)
            .setPositiveButton(R.string.ok, fromDialog)
            .show();
            */
  }

  @Override
  public void onNewLocationAvailable(Location location) {
    //    if (location == null) return;
    //    tvLocation.setOnClickListener(null);
    //    tvLocation.setText(location.getLongitude() + "\n" + location.getLatitude());
    // tvLocation.setAlpha(1.0f);
    // tvLocation.animate().alpha(0.5f).setDuration(400);
  }



  @Override
  public void onError(LocationAssistant.ErrorType type, String message) {
    // tvLocation.setText(getString(R.string.error));
  }

    @Override
    public void onNewIntent(Intent intent){
        Bundle extras = intent.getExtras();

  Log.e("INTENT","Notification Recieved");


        if(extras != null){
            if(extras.containsKey("whereToGo"))
            {
                Log.i("WhereToGo",extras.getString("whereToGo"));
                HashMap<String, String> responseMap = new HashMap<String, String>();
                responseMap.put("page",extras.getString("whereToGo"));
                if(channel!=null){
                    channel.invokeMethod("navigateToPage", responseMap);
                }
            }
        }


    }

}
