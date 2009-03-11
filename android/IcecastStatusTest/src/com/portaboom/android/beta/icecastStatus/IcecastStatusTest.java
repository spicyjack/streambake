package com.portaboom.android.beta.icecastStatus;

// java
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;

// android imports
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;
import android.widget.Toast;

public class IcecastStatusTest extends Activity {
    /** Called when the activity is first created. */
	static final String TAG = "IcecastStatusTest";
	String statPage = "http://stream.portaboom.com:7767/simple.xsl";
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
        String httpRequest = statPage, line = "";
        Log.v(TAG, "starting onCreate; statPage is " + statPage);
		try {
	        URL webURL = new URL(statPage);
	        BufferedReader is = new BufferedReader(
	            new InputStreamReader(webURL.openStream()));

			while ((line = is.readLine()) != null) {
	            httpRequest = httpRequest + line;
	        }
	        is.close();
        } catch (Throwable t) {
        	Toast 
        		.makeText(this, "Request failed: " + t.toString(), 4000);
        		//.show();
        }
        TextView tv = new TextView(this);
        tv.setText(httpRequest);
        setContentView(tv);
        //Object o = null;
        //o.toString();
        //setContentView(R.layout.main);
    }
}
