package org.ubitech.attendance;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.location.Location;
import android.os.Bundle;
import android.view.View;

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

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class MainActivity extends FlutterActivity implements LocationAssistant.Listener{

  private LocationAssistant assistant;
  private static final String CHANNEL = "location.spoofing.check";
  MethodChannel channel;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    assistant = new LocationAssistant(this, this, LocationAssistant.Accuracy.HIGH, 5000, false);
    assistant.setVerbose(true);
    channel=new MethodChannel(getFlutterView(), CHANNEL);
    GeneratedPluginRegistrant.registerWith(this);
  }
  @Override
  public void onMockLocationsDetected(View.OnClickListener fromView, DialogInterface.OnClickListener fromDialog) {
    //  tvLocation.setText(getString(R.string.mockLocationMessage));
    //  tvLocation.setOnClickListener(fromView);
    channel.invokeMethod("message", "Location is mocked");
  }

  @Override
  protected void onResume() {
    super.onResume();
    assistant.start();
  }

  @Override
  protected void onPause() {
    assistant.stop();
    super.onPause();
  }
/*
  @Override
  public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    //      if (assistant.onPermissionsUpdated(requestCode, grantResults))
    //          tvLocation.setOnClickListener(null);
  }

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

    assistant.requestAndPossiblyExplainLocationPermission();
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
