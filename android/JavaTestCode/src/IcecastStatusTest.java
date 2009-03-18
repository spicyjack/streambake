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
 * Parse the contents of the Icecast status2.xsl or simple.xsl files passed in 
 * as @param status 
*/

public class IcecastStatusTest {
	static final String statURL = "http://stream.portaboom.com:7767/simple.xsl";
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		DownloadStatusTest dst = new DownloadStatusTest();
		ParseStatusTest pst = new ParseStatusTest();
		pst.parse( dst.fetch(statURL) );
	}

}
