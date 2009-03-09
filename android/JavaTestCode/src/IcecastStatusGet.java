import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;

public class IcecastStatusGet {
	
	//String url = "http://stream.portaboom.com:7767/simple.xsl";
	static String statPage = "http://localhost:8001/simple.xsl";
	

	/**
	 * @param args
	 */

	public static void main(String[] args) {

        try {
            System.err.println("*** Loading " + statPage + "... ***");
            URL webURL = new URL(statPage);
            BufferedReader is = new BufferedReader(
                new InputStreamReader(webURL.openStream()));
            String line;
            while ((line = is.readLine()) != null) {
                System.out.println(line);
            }
            is.close();
        } catch (MalformedURLException e) {
            System.err.println("Load failed: " + e);
        } catch (IOException e) {
            System.err.println("IOException: " + e);
        } // try
	} // public static void main(String[] args)
} // public static void main(String[] args)
