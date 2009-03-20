package com.portaboom.android.beta.icecastStatus;
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
	private String returnVal = "";
	
	public String parse(String parseText) {
		String[] splitStr = parseText.split("<pre>");
		splitStr = splitStr[1].split("</pre>");
		//System.out.println("Split string 0: " + splitStr[0]);
		// splitStr[0] should be the output stripped of the XML/HTML tags
		// FIXME do a test here to see what line is being printed
		// 1) status2.xsl headers
		// 2) status2.xsl server stats
		// 3) status2.xsl mount stats
		// 4) simple.xsl server stats (split on comma, combine date blocks)
		// 5) simple.xsl headers (split on comma)
		// 6) simple.xsl mount stats (split on comma, combine date blocks)
		StringTokenizer statBlock = new StringTokenizer(splitStr[0], ";");
		//System.out.println("There are " + statBlock.countTokens() + " lines in this file");
		while ( statBlock.hasMoreTokens() == true ) {
			StringTokenizer stats = new StringTokenizer(statBlock.nextToken(), ",");
			while ( stats.hasMoreTokens() == true ) {
			//	System.out.print(stats.nextToken() + " | ");
				returnVal = returnVal +  stats.nextToken();
			}
			//System.out.println();
			returnVal = returnVal +  "\n";
		}
//		String parsed = "";
		return returnVal;
	}
}
