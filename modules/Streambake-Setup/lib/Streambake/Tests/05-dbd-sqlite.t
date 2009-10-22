#!/usr/bin/env perl

eval { use DBD::SQLite };
if ( $@ eq q() ) {
    return (
        required => q(no), 
        description => q(DBD::SQLite, database driver for SQLite databases),
        output_text => q(DBD::SQLite available, version: )
            . $DBD::SQLite::VERSION,
    );
} else { 
    die qq(DBD::SQLite not available);
}
