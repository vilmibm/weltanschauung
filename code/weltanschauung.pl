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
use DBI;
use DBIx::Interp ':all';

# thesis modules
use Corpus qw/
    normalize
    profile
    create_db
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

my $profiled_aref = profile(normalize(slurp($corpus_file)));

# XXX debug
print Dumper $profiled_aref;

my $dbh = DBI->connect("dbi:SQlite:dbname=:memory:", '', '');
my $dbx = DBIx::Interp->new($dbh)

create_db() || die 'Failed to create internal database';
insert_into_db($dbx, $profiled_aref) || die 'Failed to insert into internal database';

# XXX Algorithm
