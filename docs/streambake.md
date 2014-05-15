# Streambake #

## Todo ##
- Make a list of "actions" that modules can add/register "hooks" to/for,
  similar to how Dancer handles different URLs
- Will there be a priority between the same hook that is implemented in two
  different modules?

## Features ##
- Build Perl libraries of distro metadata
  - Libraries or binaries that are missing from the system can be output to
    the user in a message, along with suggestions on which packages should be
    installed in order to satisfy dependencies
- Link the databases between Streambake and Album Collection, so only one copy
  of the same data is stored
- Store album art in the same folder as the music files, use the suffixes
  -front/.front and -back/.back if more than one image is in the folder so you
  can tell which image to display during song/album playback
- Automagically search for album art
  - Look in the same directory as the file that is streaming
  - Look in a common directory, using Artist_Name-Album_Name as the template
    for filenames
- iOS/Android clients
  - Use Dancer/Dancer2 for the server side, and JSON for sending commands from
    clients
  - Authenticate like Amazon does for AWS commands, checksum the command plus
    the credentials, and the server can also check checksum and credentials to
    verify the command from the client
- Use HTML5 <audio> tags for adding streaming MP3's to a webpage?

vim: filetype=markdown tabstop=2
