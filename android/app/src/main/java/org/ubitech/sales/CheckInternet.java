package org.ubitech.sales;

import android.os.*;
import android.util.Log;

import java.net.*;

import io.flutter.plugin.common.MethodChannel;

class CheckInternet extends AsyncTask<String, String, String> {

    private Exception exception;
    MethodChannel methodChannel;
    public CheckInternet(MethodChannel methodChannel){
        this.methodChannel=methodChannel;
    }
    protected String doInBackground(String... urls) {
        try {
            URL url = new URL("https://ubiattendance.ubihrm.com/index.php");
            HttpURLConnection connection = null;
            connection = (HttpURLConnection) url.openConnection();
            int code = connection.getResponseCode();
            Log.i(getClass().getSimpleName(),"inside aaa");
            if(code == 200) {
                Log.i(getClass().getSimpleName(),"Internet available");
                return "Internet Available";
            } else {
                Log.i(getClass().getSimpleName(),"Internet Not available");
                return "Internet Not Available";
            }

        } catch (Exception e) {
            this.exception = e;

            return "Error Checking Internet";
        }
    }

    protected void onPostExecute(String result) {
        // TODO: check this.exception
        // TODO: do something with the feed
    }
}