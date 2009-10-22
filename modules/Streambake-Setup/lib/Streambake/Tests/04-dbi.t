#!/usr/bin/env perl

eval { use DBI };
if ( ! $@ ) {
    return (
        required => q(no), 
        description => q(DBI, database independent interface to SQL databases),
        output_text => q(DBI available, version: ) . $DBI::VERSION,
    );
} else { 
    die qq(DBD::SQLite not available);
}
