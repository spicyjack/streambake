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
 * Testing of the Pattern/Matcher classes in Java 
*/

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

public class RegexTester {
	
	public static void main(String[] args) throws IOException {
		BufferedReader in = new BufferedReader(new InputStreamReader(System.in));

		while (true) {
			System.out.print("Enter your search regex: ");
			Pattern pattern = Pattern.compile(in.readLine());
			System.out.print("Enter input string: ");
			Matcher matcher = pattern.matcher(in.readLine());

			boolean found = false;
			while (matcher.find()) {
				System.out.format("I found the text \"%s\" starting at " +
						"index %d and ending at index %d.%n",
						matcher.group(), matcher.start(), matcher.end());
				found = true;
				System.out.print("Enter replacement string: ");
				String regexedString = new String();
				regexedString = matcher.replaceAll(in.readLine());
				System.out.println("\nNew string: " + regexedString);
			}
			if(!found){
				System.out.format("No match found.%n");
			}
		}
	}
}
