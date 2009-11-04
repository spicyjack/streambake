#!/usr/bin/env perl

# this protects the test if the module is not installed/available
eval { use DBD::SQLite };
# any error text from the eval?
if ( $@ ) {
    die qq(DBD::SQLite not available);
} else { 
    return (
        required => q(no), 
        description => q(DBD::SQLite, database driver for SQLite databases),
        output_text => q(DBD::SQLite available, version: )
            . $DBD::SQLite::VERSION,
    );
} # if ( $@ )
