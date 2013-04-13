# Streambake::Util::FileReporter #

## Todo ##
- MP3 files
  - Check for valid MP3 blocks
  - Check for ID3 tags, what kind of tags the tags are, and where they are in
    the file
  - Check that the length of the ID3 tags match the length of the filename, or
    close to
    - Account for track numbers at the beginning of the file, and the `.mp3`
      extension at the end of the file

## Features ##
- Build a report showing `ID3` tags, what versions the tags are, how long each
  field is for the tag, where the tag is located in the file
  - Where in the file the `ID3` tag is located
- Bitrate, stereo, flags for MP3 files
- Automagically search for album art
  - Look in the same directory as the file that is streaming
  - Look in a common directory, using Artist_Name-Album_Name as the template
    for filenames

## MP3 File Structure ##


vim: filetype=markdown shiftwidth=2 tabstop=2
