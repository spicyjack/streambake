#!/usr/bin/env perl

eval { use DBD::Oracle };
if ( $@ eq q() ) {
    return (
        required => q(no), 
        description => q(DBD::Oracle, database driver for Oracle databases),
        output_text => q(DBD::Oracle available, version: )
            . $DBD::Oracle::VERSION,
    );
} else { 
    die qq(DBD::Oracle not available);
}
