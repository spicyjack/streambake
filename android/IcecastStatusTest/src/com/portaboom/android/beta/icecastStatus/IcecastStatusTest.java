package com.portaboom.android.beta.icecastStatus;

// apache imports
import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.BasicResponseHandler;
// android imports
import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;
import android.widget.Toast;

public class IcecastStatusTest extends Activity {
    /** Called when the activity is first created. */
	private HttpClient client;
	
	String url = "http://stream.portaboom.com:7767/status2.xsl";
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        HttpGet getMethod = new HttpGet(url);
        String rb = "";
        try {
        	ResponseHandler<String> rh = new BasicResponseHandler();
        	rb = client.execute(getMethod, rh);
        } catch (Throwable t) {
        	Toast 
        		.makeText(this, "Request failed: " + t.toString(), 4000);
        		//.show();
        }
        TextView tv = new TextView(this);
        tv.setText(rb);
        setContentView(tv);
        //Object o = null;
        //o.toString();
        //setContentView(R.layout.main);
    }
}
