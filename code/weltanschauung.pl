#!/usr/bin/perl
# who   nate smith
# what  implementation of Weltanschauung algorithm
# when  Oct 09
# why   senior thesis
# where CS488 Earlham College

use warnings;
use strict;
use lib 'lib';

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
    diminish
/;

my $db = DBIx::Simple->connect('dbi:SQLite:dbname=:memory:', '', '');

create_db($db) || die 'Failed to create internal database';

############ XXX things that are hardcoded for now but will be user-input later
my $corpus_file  = 'corborgepus';
# my $corpus_file  = 'simple_corpus';
# my $corpus_file  = 'trivial_corpus';
my $query        = 'SELECT sentence FROM lines WHERE';
my $length       = 3;
my $rhyme_scheme = ['A'];
my $syll_scheme  = [5, 7];
############

my $rule_href = {
    length       => $length       // 10,
    rhyme_scheme => $rhyme_scheme // ['A', 'B'],
    syll_scheme  => $syll_scheme  // [5, 10],
};

my $profiled_aref = profile(normalize(slurp($corpus_file)));

insert_into_db($db, $profiled_aref) || die 'Failed to insert into internal database';

my $rules = rules_parse($db, $rule_href);

my ($poem, $sentence, $sentences, $sentences_prime, $rule_prime);
for my $rule (@$rules) {
    $sentences = $db->iquery($query, $rule)->flat;
    if ( not @$sentences ) {
        $rule_prime = $rule;
        while ( $rule_prime = diminish($rule_prime) ) {
            $sentences_prime = $db->iquery($query, $rule_prime)->flat;
            $sentences = $sentences_prime and last if @$sentences_prime;
        }
    }
    $sentence = $sentences->[int rand scalar @$sentences];
    push @$poem, $sentence;            
}

print $_, "\n" for @$poem;

END {
    $db->disconnect(); # a warning is thrown about active handles, a recognized bug in DBD::SQLite
}
