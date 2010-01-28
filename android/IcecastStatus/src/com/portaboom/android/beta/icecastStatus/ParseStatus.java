package com.portaboom.android.beta.icecastStatus;
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

/* FIXME
  - parse simple.xsl (streambake/PSAS status file)
  - parse status2.xsl (Icecast default file)
*/


import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ParseStatus {
	
	public String parse(String parseText) {
		String returnText = "";
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
                returnText += "==== Server Statistics ====" + "\n";
                for ( String thisField : serverStats ) {
                    returnText += "- " + thisField + "\n";
                } // for ( String thisField : statFields )
            // mountpoint headers and stats
            } else if ( mountPointPatt.matcher(statLine).lookingAt() ) {
                statHeaders = statLine.split("\\|");
            } else {
                statFields = statLine.split("\\|");
                returnText += "==== Mount Point Statistics for " + statFields[0] + " ====\n";
                for ( int field = 0; field < statFields.length - 1; field++ ) {
                    returnText += statHeaders[field] + ": " +  statFields[field] + "\n";
                } // for ( int field = 0; field < statFields.length - 1;
            } // if ( statFields[0].matches(mountPointPatt) )
        } // for ( String statLine : statBlock )  
        return returnText;
	} // public String parse(String parseText) 
} // public class ParseStatus
