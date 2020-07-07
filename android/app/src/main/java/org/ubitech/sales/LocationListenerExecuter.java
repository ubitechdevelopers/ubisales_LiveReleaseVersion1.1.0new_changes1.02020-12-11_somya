package org.ubitech.sales;

import android.os.AsyncTask;

import io.flutter.Log;
import io.flutter.plugin.common.MethodChannel;

public class LocationListenerExecuter extends AsyncTask<String, String, String> {
private MethodChannel channel;
private MainActivity activity;
    private LocationAssistant assistant;
public LocationListenerExecuter(MethodChannel channel, MainActivity activity){
    this.channel=channel;
    this.activity=activity;
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
    public void onPreExecute(){
        if(assistant!=null)
            assistant.stop();

        Log.i("AsyncTask","Started............................");


    }

    @Override
    protected void onCancelled(String result) {
        Log.i("AsyncTask","Cancelled"+" "+result);
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
  /*  assistant = new LocationAssistant(activity, activity, LocationAssistant.Accuracy.HIGH, 1000, false,channel,10,this);
    */    //assistant.setVerbose(true);
       assistant.start();
        Log.i("AsyncTask",strings[0]);
        boolean started=true;
       while(true){
           if(isCancelled()){
               if(assistant!=null)
                   assistant.stop();
              break;
           }
       }
       return null;

    }
    catch(Exception e){

    }
        return null;
    }
    @Override
    protected void onPostExecute(String result) {
            Log.i("AsyncTask","completed");
    }
    public void endThread(){
        if(!isCancelled()){
            Log.i("AsyncTask","completed");
            this.cancel(true);
        }

    }
}
