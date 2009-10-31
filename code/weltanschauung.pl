# who   nate smith
# what  implementation of Weltanschauung algorithm
# when  Oct 09
# why   senior thesis
# where CS488 Earlham College

use warnings;
use strict;

# CPAN modules
use File::Slurp 'slurp';

# thesis modules
use corpus qw/
    normalize
    profile
    insert_into_db
/;
use rules qw/
    rules_parse
    rule_to_query
    query_to_rule
    decompose
/;

# XXX hardcoded for now
my $corpus_file = 'corborgepus';

my $corpus_str = slurp( $corpus_file );

my $profiled_aref = profile normalize slurp $corpus_file;

#my $lines_aref = normalize($corpus_str);

#my $profiled_aref = profile($lines_aref);


