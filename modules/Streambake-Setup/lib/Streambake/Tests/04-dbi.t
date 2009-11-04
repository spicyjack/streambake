#!/usr/bin/env perl

# this protects the test if the module is not installed/available
eval { use DBI };
# any error text from the eval?
if ( $@ ) {
    die qq(DBI not available);
} else { 
    return (
        required => q(no), 
        description => q(DBI, database independent interface to SQL databases),
        output_text => q(DBI available, version: ) . $DBI::VERSION,
    );
} # if ( $@ )
