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

import java.util.StringTokenizer;

public class ParseStatusTest {

	public void parse(String parseText) {
		StringTokenizer st = new StringTokenizer(parseText, ",");
		System.out.println("There are " + st.countTokens() + " tokens in this file");
		while (st.hasMoreTokens() == true) {
			System.out.print(st.nextToken() + " | ");
		}
//		String parsed = "";
//		return parsed;
	}
}
