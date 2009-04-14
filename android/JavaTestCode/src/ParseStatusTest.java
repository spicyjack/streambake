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

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ParseStatusTest {

	public void parse(String parseText) {
		String[] htmlSplitText = parseText.split("<pre>");
		htmlSplitText = htmlSplitText[1].split("</pre>");
		Pattern ampPatt = Pattern.compile("&amp;");
		Matcher ampMatch = ampPatt.matcher(htmlSplitText[0]);
		String filteredString = ampMatch.replaceAll("&");
		//System.out.println("Split string 0: " + htmlSplitText[0]);
		// htmlSplitText[0] should be the output stripped of the XML/HTML tags
        // split the HTML output on semicolons, this gets us the lines of
        // output
		String[] statBlock = filteredString.split(";");
        // these only get set once below
        String[] serverStats = {};
        String[] statHeaders = {};
        // for each line of output...
		for ( String statLine : statBlock ) {
            // this gets reset through every loop
            String[] statFields = {};
		    Pattern serverStartPatt = Pattern.compile("^Server Start");
		    Pattern mountPointPatt = Pattern.compile("^Mount Point");
            // server stats
            if ( serverStartPatt.matcher(statLine).lookingAt() ) {
                serverStats = statLine.split("\\|");
                System.out.println("==== Server Statistics ====");
                for ( String thisField : serverStats ) {
    	            System.out.println("- " + thisField);		
                } // for ( String thisField : statFields )
            // mountpoint headers and stats
            } else if ( mountPointPatt.matcher(statLine).lookingAt() ) {
                statHeaders = statLine.split("\\|");
            } else {
                statFields = statLine.split("\\|");
                System.out.println(
                    "==== Mount Point Statistics for " 
                    + statFields[0] + " ====");
                for ( int field = 0; field < statFields.length - 1; field++ ) {
    	            System.out.println(statHeaders[field] 
                        + ": " +  statFields[field]);
                } // for ( int field = 0; field < statFields.length - 1;
            } // if ( statFields[0].matches(mountPointPatt) )
		} // for ( String statLine : statBlock )
	} // public void parse(String parseText)
} // public class ParseStatusTest
