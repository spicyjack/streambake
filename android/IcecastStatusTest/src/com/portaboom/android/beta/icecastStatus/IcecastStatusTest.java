package com.portaboom.android.beta.icecastStatus;

/**
 * $Id$
 * 
 * @author elspicyjack at gmail dot com
 * @version $Revision$
 *
 * NOTE: Please do not e-mail the author directly regarding this code.  
 * The proper forum for support is the Streambake Google Groups list at
 * http://groups.google.com/group/streambake or <streambake@groups.google.com>
 * 
 * Parse the contents of the Icecast status2.xsl or simple.xsl files passed in 
 * as @param status 
*/

// java
//import java.io.BufferedReader;
//import java.io.InputStreamReader;
//import java.net.URL;

// android imports
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;
import android.widget.Toast;

public class IcecastStatusTest extends Activity {
    /** Called when the activity is first created. */
        static final String TAG = "IcecastStatusTest";
        String statURL = "http://stream.portaboom.com:7767/simple.xsl";
        String fetchedText = "";
        
        @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.v(TAG, "starting onCreate; statURL is " + statURL);
        try {
        	DownloadStatusTest dst = new DownloadStatusTest();
        	fetchedText = dst.fetch(statURL);
        } catch (Throwable t) {
        	Toast 
            .makeText(this, "Request failed: " + t.toString(), 4000);
            //.show();
        }

        ParseStatusTest pst = new ParseStatusTest();
        TextView tv = new TextView(this);
        tv.setText( "Fetched: " + statURL + "\n" + pst.parse( fetchedText ) );
        setContentView(tv);
        //Object o = null;
        //o.toString();
        //setContentView(R.layout.main);
    }
}

