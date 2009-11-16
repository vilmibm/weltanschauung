# who   nate smith
# what  implementation of Weltanschauung algorithm
# when  Oct 09
# why   senior thesis
# where CS488 Earlham College

use warnings;
use strict;

use Data::Dumper; # XXX debug

# CPAN modules
use File::Slurp 'slurp';
use DBIx::Simple;

# thesis modules
use Corpus qw/
    normalize
    profile
    create_db
    insert_into_db
/;
use Rules qw/
    rules_parse
    rule_to_query
    query_to_rule
    decompose
/;

my $db = DBIx::Simple->connect('dbi:SQLite:dbname=:memory:', '', '');

create_db($db) || die 'Failed to create internal database';

############ XXX things that are hardcoded for now but will be user-input later
# my $corpus_file  = 'corborgepus';
# my $corpus_file  = 'simple_corpus';
my $corpus_file  = 'trivial_corpus';
my $length       = 10;
my $rhyme_scheme = 'AB';
my $syll_scheme  = [5, 10];
############

my $profiled_aref = profile(normalize(slurp($corpus_file)));

insert_into_db($db, $profiled_aref) || die 'Failed to insert into internal database';

my $rules = rules_parse($length, $rhyme_scheme, $syll_scheme); # XXX this signature will probably change

my $queries = [];

push @$queries, rule_to_query($_) for @$rules;

my $sentence;
for my $query (@$queries) {
    #$sentence = $db->selectall_
}

END {
    $db->disconnect(); # a warning is thrown about active handles, a recognized bug in DBD::SQLite
}
