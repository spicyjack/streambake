package com.portaboom.android.icecastStatus;

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
*/

/* FIXME
- Pass this object in to the downloader and parser so that they can make
  callbacks when needed
- abstract the status URL; the user should be able to enter the server name
  and port in a dialog somewhere and different URL's can be tried 
  in the order of most preferred to least preferred until a URL 
  is found that doesn't 404
- Call the Prefs screen if the application is started and there's
  no URL set in the properties for this application
*/

// android imports
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;
// local imports
import com.portaboom.android.icecastStatus.DialogURLFetch;

public class IcecastStatus extends Activity {
        static final String LOGTAG = "IcecastStatus";
        private String statURL = "http://stream.portaboom.com:7767";
        private String fetchedText = "";

    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
    	Log.d(LOGTAG, "entering onCreate; statURL is " + statURL);
    	super.onCreate(savedInstanceState);
        Log.d(LOGTAG, "starting DialogURLFetch intent");
        // pop up the dialog that shows what base URL 
        // we will be downloading from
        DialogURLFetch durlf = new DialogURLFetch();
        
        //if ( durlf != null ) {
        //	durlf.startIntent(statURL);
    	//}
        // create the fetching object
        HTTPStatusDownload hsd = new HTTPStatusDownload();
        // try and fetch the status URL
        Log.d(LOGTAG, "Fetching statURL: " + statURL);
        try {
        	fetchedText = hsd.fetch(statURL);
        } catch (Throwable t) {
        	Toast 
            .makeText(this, "Request failed: " + t.toString(), 4000);
            //.show();
        }

        // create the output text box
        Log.d(LOGTAG, "Parsing output of statURL");
        ParseStatus pst = new ParseStatus();
        TextView tv = new TextView(this);
        tv.setText( "Status URL: " + statURL + "\n" + pst.parse( fetchedText ) );
        ScrollView sv = new ScrollView(this);
        sv.addView(tv);
        setContentView(sv);
        //Object o = null;
        //o.toString();
        //setContentView(R.layout.main);
    }
}

