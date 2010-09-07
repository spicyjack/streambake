#!/usr/bin/perl -w

# Walks thru a mp3main table, and checks for corresponding files on the
# filesystem; also executes find(1L), and checks for files on the filesystem
# that are not in the database.  Updates the check date in the database entry
# when that file has been verified on the filesystem

# Uses DBI
	use DBI;

# Database variables
$outdb = 'mp3db';           #Database to check
$outtable = 'mp3main';      #Table to check
$sqlserver = 'localhost';   #SQL server to use
$sqluser = 'root';  		#SQL username
$sqlpass = 'password!';   #SQL password


	# make sure we were passed a path to search for MP3's
	if ( $ARGV[0] eq "" ) { 
		print "You must enter a path to your MP3's;  Exiting...\n";
		exit 1;
	}	
	
	# call system(find $path) to get a list of MP3's	
	print "Executing system(find)...\n";
	@filelist = `find $ARGV[0] -name \"*.mp3\" -print`;

	# open the database connection
	$dbh = DBI->connect("DBI:mysql:$outdb:$sqlserver", $sqluser, $sqlpass)
    	|| die("Connect error: $DBI::errstr");


	$total_lines = 0; # set a line counter 
	$valid_counter = 1; # counter for valid song dots

	# read in each line of the 'find', then run it against the database
	foreach $file (@filelist) {
		chomp($file);
		# this stuff is for updating the filesize in the database
		@filestat = stat($file);
		$filesize = $filestat[7];	

		# the SQL select statement
		$selectsql = "SELECT song_id FROM $outtable
			WHERE concat(filedir, '/', filename) = \"$file\" ";

		# run the select query
		$sthselect = $dbh->prepare($selectsql);
		$sthselect->execute();

		# set the total ID numbers found
		$total_ids = 0; # total rows returned from each select

		# now go get the song_id, use while for fetching the return values,
		# there may be more than one file entry into the database

		while (@row = $sthselect->fetchrow_array ) {
			if ($row[0] > 0 && $total_ids == 0) { # if we got back a song_id
				$song_id = $row[0];

				# the update query

				# this one does filesize as well as verify the song
				$updatesql = "UPDATE LOW_PRIORITY $outtable SET 
					filesize = \"$filesize\", verify_date = NULL
					WHERE song_id = $song_id";

				# this one only verifies the song on the filesystem
				#$updatesql = "UPDATE LOW_PRIORITY $outtable SET 
				#	verify_date = NULL WHERE song_id = $song_id";

				# execute it
				$sthupdate = $dbh->prepare($updatesql);
				$sthupdate->execute();

				# print a dot
				print ".";
				$valid_counter++;
				if ($valid_counter == 70) { # if end of the line
					$valid_counter = 1; # reset the counter
					print " $total_lines\n"; # and start a new line
				} # if $valid_counter
				$total_ids++;
			} elsif ($row[0] > 0) { # duplicate song, song_id is higher than 0
				print "\nDuplicate: " . $song_id . " -> " .
					$file . "\n";
			} else { # song_id was 0, something screwy happened
				print "\nError: Returned song_id = $song_id .  Exiting\n";
			} # if $row[0]
		} # while @row

		# update total input lines parsed
		$total_lines++;
	} # foreach $file (@filelist)

	$dbh->disconnect;

	# tell'em how we did...
	print "\nProcessed $total_lines total files\n";

exit 0;
