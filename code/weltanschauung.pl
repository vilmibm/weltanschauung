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
use Getopt::Long;

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
    diminish
/;

my $query        = 'SELECT sentence FROM lines WHERE';
my $db;
my $profiled_aref;

############ user args handling
#my $corpus_file   = 'corborgepus';
#my $corpus_file   = 'simple_corpus';
#my $corpus_file   = 'trivial_corpus';
my $corpus_file;
my $generate_only = 0;
my $preload;
my $db_file;
my $rhyme_str     = '';
my $syll_str      = "5,7";
my $length        = 3;


_handle_args();
sub _connect_db() {
    my $filename = shift || ':memory:';
    return DBIx::Simple->connect("dbi:SQLite:dbname=$filename", '', '');
}
sub _handle_args() {
    Getoptions(
        'generate_only' => \$generate_only,
        'preload'       => \$preload,
        'corpus=s'      => \$corpus_file,
        'db=s'          => \$db_file,
        'length=i'      => \$length,
        'rhyme=s'       => \$rhyme_str,
        'syl=s'         => \$syll_str,
    );
    if ( $preload ) {
        die 'Must specify DB for preload option' unless $db_file;
        $db = _connect_db($db_file);
        return;
    }

    $db = _connect_db();

    # rest...
}





# !db,!c,!g
#     -not allowed
# !db,c,g
#     -not allowed
# db,!c,g
#     -not allowed
# !db,!c,g
#     -not allowed
if ( 
    (!$db_file && !$corpus_file && !$generate_only) ||
    (!$db_file &&  $corpus_file &&  $generate_only) ||
    ( $db_file && !$corpus_file &&  $generate_only) ||
    (!$db_file && !$corpus_file &&  $generate_only)
) { die 'Bad arguments.' }

$db_file ?
   $db = DBIx::Simple->connect("dbi:SQLite:dbname=$db_file", '', '')
:  $db = DBIx::Simple->connect("dbi:SQLite:dbname=:memory:", '', '')

if ( $corpus_file ) {
    $profiled_aref = profile(normalize(slurp($corpus_file)));

}

# db,c,!g
#     -generate from c, save in db
if  ( $db_file && $corpus_file && !$generate_only) {
    $db = DBIx::Simple->connect("dbi:SQLite:dbname=$db_file", '', '');
    $profiled_aref = profile(normalize(slurp($corpus_file)));
    create_db($db) || die 'Failed to create internal database'
    insert_into_db($db, $profiled_aref) || die 'Failed to insert into internal database';
}
# db,c,g
#     -generate from c, save in db, exit
if  ( $db_file && $corpus_file && $generate_only) {
    $db = DBIx::Simple->connect("dbi:SQLite:dbname=$db_file", '', '');
    $profiled_aref = profile(normalize(slurp($corpus_file)));
    create_db($db) || die 'Failed to create internal database'
    insert_into_db($db, $profiled_aref) || die 'Failed to insert into internal database';
    exit "db saved in $db_file";
}
# !db,c,!g
#     -generate from c, save in :memory:
if  ( !$db_file && $corpus_file && !$generate_only) {
    $db_file = ':memory:'
    $db = DBIx::Simple->connect("dbi:SQLite:dbname=$db_file", '', '');
    $profiled_aref = profile(normalize(slurp($corpus_file)));
    create_db($db) || die 'Failed to create internal database'
    insert_into_db($db, $profiled_aref) || die 'Failed to insert into internal database';
}

#### begin.
my ($rhyme_scheme, $syll_scheme);
$rhyme_scheme = \(split ',', $rhyme_str);
$syll_scheme  = \(split ',', $syll_str );

my $rule_href = {
    length       => $length,
    rhyme_scheme => $rhyme_scheme,
    syll_scheme  => $syll_scheme,
};

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
