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
- Add callbacks that other objects can use to prompt this object to do
  something
  - server URL and port to connect to?
- Abstract the URL; the URL could be put together in this object using only
  the base
  - try for simple.xsl first (streambake/PSAS status file)
  - try for status2.xsl (Icecast default file)
*/

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;

import android.util.Log;

public class HTTPStatusDownload {
	static final String TAG = "IcecastStatus";
	/**
     * Fetch the URL passed in as as @param statURL 
	 * @param statURL The URL to fetch and parse the output of 
	 */

	public String fetch(String statURL) {
		
		String line = "", returnHTML = "";
		int linesRead = 0;
        try {
            //System.err.println("*** Loading " + statURL + "... ***");
            URL webURL = new URL(statURL);
            BufferedReader is = new BufferedReader(
                new InputStreamReader(webURL.openStream()));
            while ((line = is.readLine()) != null) {
                returnHTML = returnHTML + line;
                linesRead++;
            }
            is.close();
        } catch (MalformedURLException e) {
            System.err.println("Load failed: " + e);
        } catch (IOException e) {
            System.err.println("IOException: " + e);
        } // try
//        System.out.println("Downloaded status is:");
//        System.out.println(returnHTML);
        Log.v(TAG, "Read " + linesRead + " from " + statURL);
        return returnHTML;
	} // public static void main(String[] args)
} // public class HTTPStatusDownload
