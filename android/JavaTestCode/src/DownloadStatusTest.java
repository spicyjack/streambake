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


import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.io.FileReader;
import java.io.FileNotFoundException;

public class DownloadStatusTest {

	/**
	 * @param statURL The URL to fetch and parse the output of 
	 */

	public String fetchURL(String statURL) {
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
//        System.out.println("Downloaded status is:");
//        System.out.println(returnHTML);
        return returnHTML;
	} // public static void main(String[] args)

    public String readFile(String fileName) {
		String line = "", returnText = "";
        try {
            //System.err.println("*** Loading " + statURL + "... ***");
            BufferedReader is = new BufferedReader(new FileReader(fileName));
            while ((line = is.readLine()) != null) {
                returnText = returnText + line;
            }
            is.close();
        } catch (FileNotFoundException e) {
            System.err.println("Read file failed: " + e);
        } catch (IOException e) {
            System.err.println("IOException: " + e);
        } // try
//        System.out.println("Downloaded status is:");
//        System.out.println(returnHTML);
        return returnText;
       
    } // public String readFile(String fileName)
} // public static void main(String[] args)
