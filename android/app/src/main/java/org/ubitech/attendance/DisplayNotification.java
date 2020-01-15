package org.ubitech.attendance;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;

import androidx.core.app.NotificationCompat;

public class DisplayNotification {
    private Context ctx;
    public DisplayNotification(Context ctx){
        this.ctx=ctx;
    }

    public void displayNotification(String title, String task,String pageToOpenOnClick) {
        try{
        NotificationManager notificationManager = (NotificationManager) ctx.getSystemService(Context.NOTIFICATION_SERVICE);

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel("simplifiedcoding", "simplifiedcoding", NotificationManager.IMPORTANCE_DEFAULT);
            notificationManager.createNotificationChannel(channel);
        }

        NotificationCompat.Builder notification = new NotificationCompat.Builder(ctx, "simplifiedcoding")
                .setContentTitle(title)
                .setContentText(task)
                //.setAutoCancel(true)
                .setSmallIcon(R.mipmap.ic_launcher);

            Intent notificationIntent = new Intent(ctx, MainActivity.class);
            notificationIntent.putExtra("whereToGo", pageToOpenOnClick);
           notificationIntent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_CLEAR_TOP);
            PendingIntent contentIntent = PendingIntent.getActivity(ctx,0,notificationIntent,PendingIntent.FLAG_UPDATE_CURRENT);


        notification.setContentIntent(contentIntent);
        notificationManager.notify(1, notification.build());
    }catch (Exception e){
            e.printStackTrace();
        }
    }

}
