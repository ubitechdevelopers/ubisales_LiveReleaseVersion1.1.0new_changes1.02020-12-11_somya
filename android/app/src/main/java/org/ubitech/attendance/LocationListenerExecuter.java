package org.ubitech.attendance;

import android.app.Activity;
import android.os.AsyncTask;

import io.flutter.plugin.common.MethodChannel;

public class LocationListenerExecuter extends AsyncTask<String, String, String> {
private MethodChannel channel;
private MainActivity activity;
    private LocationAssistant assistant;
public LocationListenerExecuter(MethodChannel channel, MainActivity activity){
    this.channel=channel;
    this.activity=activity;
}
    public boolean onPermissionsUpdated(int requestCode, int[] grantResults){
        return assistant.onPermissionsUpdated(requestCode, grantResults);
    }
    public void requestLocationPermission(){
    if(assistant!=null)
    assistant.requestLocationPermission();
    }
    public void onDestroy(){
        assistant.stop();
    }

    public void manuallyStartAssistant(){
    if(assistant!=null){
        assistant.forceStart();
    }

    }

    public void requestAndPossiblyExplainLocationPermission(){
        if(assistant!=null)
    assistant.requestAndPossiblyExplainLocationPermission();
    }
    public void updateCameraStatus(boolean cameraStatus){
        if(assistant!=null)
     assistant.updateCameraStatus(cameraStatus);
    }
    public void startAssistant(){
    if(assistant!=null)
        assistant.start();
    } public void stopAssistant(){
        assistant.stop();
    }
    @Override
    protected String doInBackground(String... strings) {
        assistant = new LocationAssistant(activity, activity, LocationAssistant.Accuracy.HIGH, 1000, false,channel,10);
        assistant.setVerbose(true);
       assistant.start();

        return null;
    }
}
