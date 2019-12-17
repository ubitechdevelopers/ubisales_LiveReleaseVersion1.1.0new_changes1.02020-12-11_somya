package org.ubitech.attendance;

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
    try{
        return assistant.onPermissionsUpdated(requestCode, grantResults);
    }
    catch(Exception e){
        return false;
    }
    }
/*
    public void requestLocationPermission(){
    try{
    if(assistant!=null)
    assistant.requestLocationPermission();
    }
    catch(Exception e){

    }
    }*/
    public void onDestroy(){
     try{
        assistant.stop();
     }
     catch(Exception e){

     }
    }

    public void manuallyStartAssistant(){
    try {
        if (assistant != null) {
            assistant.forceStart();
        }
    }
    catch(Exception e){

    }
    }
/*
    public void requestAndPossiblyExplainLocationPermission(){
     try{
        if(assistant!=null)
    assistant.requestAndPossiblyExplainLocationPermission();
     }
     catch(Exception e){

     }
    }*/
    /*
    public void updateCameraStatus(boolean cameraStatus){
    try{
        if(assistant!=null)
     assistant.updateCameraStatus(cameraStatus);
    }
    catch(Exception e){

    }
    }*/
    public void startAssistant(){
    try{
    if(assistant!=null)
        assistant.start();
    }
    catch(Exception e){

    }
    } public void stopAssistant(){
     try{
         if(assistant!=null)
        assistant.stop();
     }
     catch(Exception e){

     }
    }
    @Override
    protected String doInBackground(String... strings) {
    try{
    assistant = new LocationAssistant(activity, activity, LocationAssistant.Accuracy.HIGH, 1000, false,channel,10);
        //assistant.setVerbose(true);
       assistant.start();
    }
    catch(Exception e){

    }
        return null;
    }
}
