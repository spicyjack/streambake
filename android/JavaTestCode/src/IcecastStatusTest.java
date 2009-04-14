
/**
 * $Id$
 * 
 * @author elspicyjack at gmail dot com
 * @version $Revision$
 *
 * NOTE: Please do not e-mail the author directly regarding this code.  
 * The proper forum for support is the Streambake Google Groups list at
 * http://groups.google.com/group/streambake or streambake@groups.google.com
 * 
 * Parse the contents of the Icecast status2.xsl or simple.xsl files passed in 
 * as @param status 
*/

// FIXME add a call to getopts so you can change the URL if you want
import java.io.File;

public class IcecastStatusTest {
	static final String statURL = "http://stream.portaboom.com:7767/simple.xsl";
    static final String fileName = "test.html";
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		DownloadStatusTest dst = new DownloadStatusTest();
		// FIXME read the file here
		ParseStatusTest pst = new ParseStatusTest();
        File parseFile = new File(fileName);
        // use the local file first if the file exists
        if ( parseFile.exists() ) {
            System.out.println("File " + fileName + " found...");
    		pst.parse( dst.readFile(fileName) );
        } else {
    		pst.parse( dst.fetchURL(statURL) );
        } // if ( parseFile.exists() )
	} // public static void main(String[] args)
} // public class IcecastStatusTest
