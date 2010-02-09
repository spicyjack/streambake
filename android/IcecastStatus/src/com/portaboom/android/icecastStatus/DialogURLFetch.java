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

package com.portaboom.android.icecastStatus;

//android imports
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

public class DialogURLFetch extends Activity {
	static final String LOGTAG = "DialogURLFetch"; // for log messages
	
    /** Called when the intent is started in a different class */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(LOGTAG, "Entering onCreate");
        setContentView(R.layout.dialog_url_fetch);
    } // public void onCreate(Bundle savedInstanceState)
    
} // public class DialogURLFetch extends Activity
