package org.ubitech.attendance;

import android.Manifest;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.location.Location;
import android.os.Bundle;
import android.os.StrictMode;
import android.view.View;

import io.flutter.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.location.Location;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import android.os.Bundle;

import java.lang.reflect.Method;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import android.hardware.Camera;

import androidx.core.app.ActivityCompat;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;

public class MainActivity extends FlutterActivity implements LocationAssistant.Listener{

  private LocationAssistant assistant;
  private static final String CHANNEL = "location.spoofing.check";
  private static final String CAMERA_CHANNEL = "update.camera.status";
  private boolean cameraOpened=false;

  MethodChannel channel;
  LocationListenerExecuter listenerExecuter;
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    if (android.os.Build.VERSION.SDK_INT > 9)
    {
      StrictMode.ThreadPolicy policy = new
              StrictMode.ThreadPolicy.Builder().permitAll().build();
      StrictMode.setThreadPolicy(policy);
    }
      ActivityCompat.requestPermissions(this,
              new String[]{Manifest.permission.CAMERA,Manifest.permission.ACCESS_FINE_LOCATION}, 1);

    channel=new MethodChannel(getFlutterView(), CHANNEL);
    GeneratedPluginRegistrant.registerWith(this);
    listenerExecuter=new LocationListenerExecuter(channel,this);
    listenerExecuter.execute("");
      Timer timer = new Timer();

      new MethodChannel(getFlutterView(), CAMERA_CHANNEL).setMethodCallHandler(
            new MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, Result result) {
                if (call.method.equals("cameraOpened")) {
                  cameraOpened=true;
                  Log.i("camera","camera opened true");
                 listenerExecuter.updateCameraStatus(true);
                }
                else
                if (call.method.equals("cameraClosed")) {
                  Log.i("camera","camera opened false");
                  cameraOpened=false;
                  listenerExecuter.updateCameraStatus(false);
                }
                else
                if (call.method.equals("startAssistant")) {
                  Log.i("Assistant","Assistant Start Called");

                  manuallyStartAssistant();
                }
                if (call.method.equals("startTimeOutNotificationWorker")) {
                 // Log.i("Assistant","Assistant Start Called");
                  String ShiftTimeOut = call.argument("ShiftTimeOut");
                  Log.i("ShiftTimeout",ShiftTimeOut);
                 startTimeOutNotificationWorker(ShiftTimeOut);
                }

              }
            });



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
    long differenceinMilli =  date1.getTime()-date2.getTime();
    minutes = TimeUnit.MILLISECONDS.toMinutes(differenceinMilli);
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

Log.i("WorkerMinutes",minutes+"");
  final OneTimeWorkRequest workRequest = new OneTimeWorkRequest.Builder(TimeOutNotificationWork.class)
          .setInitialDelay(minutes, TimeUnit.MINUTES)
          .build();
  WorkManager.getInstance().enqueue(workRequest);
}

  public void manuallyStartAssistant(){
    if(listenerExecuter!=null)
    listenerExecuter.manuallyStartAssistant();
  }
  @Override
  public void onMockLocationsDetected(View.OnClickListener fromView, DialogInterface.OnClickListener fromDialog) {
    //  tvLocation.setText(getString(R.string.mockLocationMessage));
    //  tvLocation.setOnClickListener(fromView);
   // channel.invokeMethod("message", "Location is mocked");
  }
  @Override
  public void onDestroy() {

    listenerExecuter.onDestroy();

    super.onDestroy();

  }
  @Override
  protected void onResume() {
    super.onResume();
   if(!cameraOpened)
    listenerExecuter.startAssistant();
   // assistant.start();
  }

  @Override
  protected void onPause() {
   // assistant.stop();
  //if(!cameraOpened)
    listenerExecuter.stopAssistant();
    super.onPause();
  }

  @Override
  public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    if(permissions!=null&&permissions.length>0)
   Log.i("Perrrrr",permissions[0]+grantResults);
         if (listenerExecuter.onPermissionsUpdated(requestCode, grantResults));

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
   listenerExecuter.requestLocationPermission();
    listenerExecuter.requestAndPossiblyExplainLocationPermission();
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

}
