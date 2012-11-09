<map version="1.0.0">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1233304395904" ID="Freemind_Link_1654792231" MODIFIED="1352420443320" TEXT="Streambake Classes">
<richcontent TYPE="NOTE"><html>
  <head>
    
  </head>
  <body>
    <p>
      - Rip test CD's, tag with metadata and images<br />&#160;&#160;- You could also use the pre-ripped WAV files with the discid<br />- Write test classes<br />- Write Streambake::Media classes that work with the tests<br />- Write a 'setup.pl' script that verifies Perl modules and external binaries<br />&#160;&#160;(tests for versions on external binaries)
    </p>
  </body>
</html>
</richcontent>
<node CREATED="1233304631794" ID="_" MODIFIED="1233305050060" POSITION="right" TEXT="Streambake::Gaffer (Master)">
<node CREATED="1233305190788" ID="Freemind_Link_1474575991" MODIFIED="1233305206423" TEXT="Gets files to play from all of the different sources"/>
<node CREATED="1233305250942" ID="Freemind_Link_1570967488" MODIFIED="1233305261689" TEXT="Forks into the backround if requested"/>
<node CREATED="1233305265982" ID="Freemind_Link_211643414" MODIFIED="1233305273858" TEXT="Answers requests on admin ports">
<node CREATED="1233305274783" ID="Freemind_Link_997947630" MODIFIED="1233305288738" TEXT="Threaded admin server?"/>
</node>
</node>
<node CREATED="1233304989950" ID="Freemind_Link_405302902" MODIFIED="1233305034779" POSITION="left" TEXT="Streambake::Streamer">
<node CREATED="1233305210093" ID="Freemind_Link_1728015199" MODIFIED="1241810806084" TEXT="Reads files from the filesystem"/>
<node CREATED="1233305219677" ID="Freemind_Link_824648443" MODIFIED="1233305225305" TEXT="Reencodes files as needed"/>
<node CREATED="1233305227453" ID="Freemind_Link_995449501" MODIFIED="1241810731711" TEXT="Sends the MP3/OGG data to the server"/>
<node CREATED="1233305240549" ID="Freemind_Link_48684663" MODIFIED="1233305247218" TEXT="Definitely threaded"/>
</node>
<node CREATED="1233305302896" ID="Freemind_Link_724834274" MODIFIED="1233305307899" POSITION="right" TEXT="Streambake::Media">
<node CREATED="1233305309088" ID="Freemind_Link_120971738" MODIFIED="1233305319628" TEXT="Streambake::Media::CDAudio">
<node CREATED="1233904751094" ID="Freemind_Link_1775146328" MODIFIED="1234341343352" TEXT="Audio::CDDB"/>
<node CREATED="1234341354045" ID="Freemind_Link_526298554" MODIFIED="1234341360064" TEXT="Audio::CD::Data"/>
</node>
<node CREATED="1234341261094" ID="Freemind_Link_1581568612" MODIFIED="1234341269074" TEXT="Streambake::Media::File">
<node CREATED="1233904763014" ID="Freemind_Link_183115950" MODIFIED="1233904767402" TEXT="MP3::Tag"/>
<node CREATED="1233904769103" ID="Freemind_Link_908664569" MODIFIED="1234341652590" TEXT="Audio::TagLib"/>
</node>
</node>
<node CREATED="1233478646589" ID="Freemind_Link_522835197" MODIFIED="1241810779554" POSITION="left" TEXT="Streambake::Check">
<node CREATED="1233478663405" ID="Freemind_Link_985722942" MODIFIED="1241810841005" TEXT="Allows for checks before streaming a file"/>
<node CREATED="1233478683317" ID="Freemind_Link_1964702150" MODIFIED="1233478693521" TEXT="Streambake::Check::SkipFile"/>
<node CREATED="1233478694974" ID="Freemind_Link_747898751" MODIFIED="1233478703009" TEXT="Streambake::Check::Rating"/>
<node CREATED="1234341208331" ID="Freemind_Link_1042903480" MODIFIED="1234341217908" TEXT="Streambake::Check::FileExists"/>
<node CREATED="1234341218670" ID="Freemind_Link_1072411722" MODIFIED="1234341239882" TEXT="Streambake::Check::ShareAvailable"/>
</node>
<node CREATED="1241810645822" ID="Freemind_Link_762404898" MODIFIED="1241810651822" POSITION="right" TEXT="Streambake::Source">
<node CREATED="1241810652431" ID="Freemind_Link_1289622967" MODIFIED="1241810656493" TEXT="File"/>
<node CREATED="1241810657853" ID="Freemind_Link_1282600560" MODIFIED="1241810662915" TEXT="iPod"/>
<node CREATED="1241810665649" ID="Freemind_Link_786876555" MODIFIED="1241810667696" TEXT="HTTP"/>
<node CREATED="1241810668978" ID="Freemind_Link_1099182109" MODIFIED="1241810671196" TEXT="FTP"/>
</node>
</node>
</map>
