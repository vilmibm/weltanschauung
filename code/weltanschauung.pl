# who   nate smith
# what  implementation of Weltanschauung algorithm
# when  Oct 09
# why   senior thesis
# where CS488 Earlham College

use warnings;
use strict;

# CPAN modules
use File::Slurp 'slurp';
# XXX debug
use Data::Dumper;

# thesis modules
use Corpus qw/
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
#my $corpus_file = 'corborgepus';
my $corpus_file = 'simple_corpus';

my $profiled_aref = profile( normalize( slurp( $corpus_file)));

print Dumper $profiled_aref;
