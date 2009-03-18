/**
 * $Id: OfficeRunner.java,v 1.1 2009-02-10 07:50:42 brian Exp $
 * 
 * @author elspicyjack at gmail dot com
 * @version $Revision: 1.1 $
 *
 * NOTE: Please do not e-mail the author directly regarding this code.  
 * The proper forum for support is the Streambake Google Groups list at
 * http://groups.google.com/group/streambake or <streambake@groups.google.com>
 * 
 * Fetch the URL passed in as as @param statURL 
*/

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;

public class DownloadStatusTest {

	/**
	 * @param statURL The URL to fetch and parse the output of 
	 */

	public String fetch(String statURL) {
		String line = "", returnHTML = "";
        try {
            //System.err.println("*** Loading " + statURL + "... ***");
            URL webURL = new URL(statURL);
            BufferedReader is = new BufferedReader(
                new InputStreamReader(webURL.openStream()));
            while ((line = is.readLine()) != null) {
                returnHTML = returnHTML + line;
            }
            is.close();
        } catch (MalformedURLException e) {
            System.err.println("Load failed: " + e);
        } catch (IOException e) {
            System.err.println("IOException: " + e);
        } // try
        return returnHTML;
	} // public static void main(String[] args)
} // public static void main(String[] args)
