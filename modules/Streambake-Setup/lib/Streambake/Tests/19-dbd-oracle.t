#!/usr/bin/env perl

# this protects the test if the module is not installed/available
eval { use DBD::Oracle };

    return (
        required => q(no), 
        description => q(DBD::Oracle, database driver for Oracle databases),
        output_text => q(DBD::Oracle available, version: ) 
            . $DBD::Oracle::VERSION,
    );
