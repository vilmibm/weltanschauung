#!/usr/bin/perl
# who   nate smith
# what  implementation of Weltanschauung algorithm
# when  Oct 09
# why   senior thesis
# where CS488 Earlham College

use warnings;
use strict;
use lib 'lib';
use feature ':5.10';
use List::Util 'max';

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
    rule_set_to_query
    weaken_rule_set
/;

my $db;
my $profiled_aref;

############ user args handling
#my $corpus_file   = 'corborgepus';
#my $corpus_file   = 'simple_corpus';
#my $corpus_file   = 'trivial_corpus';
my $corpus_file;
my $generate_only = 0;
my $preload       = 0;
my $db_file;
my $rhyme_str     = '';
my $syll_str      = '';
my $exact_keyword_str = '';
my $fuzzy_keyword_str = '';
my $length        = 3;

#### begin.

my $rule_sets = rules_parse($db, _handle_args());

my ($query, $poem, $sentence, $sentences, $sentences_prime, $rule_set_prime);
for my $rule_set (@$rule_sets) {
    $query = rule_set_to_query($rule_set);
    warn Dumper $query;
    $sentences = $db->query($query)->flat;
    if ( not @$sentences ) {
        $rule_set_prime = [@$rule_set];
        while ( $rule_set_prime = weaken_rule_set($rule_set_prime) ) {
            $query = rule_set_to_query($rule_set_prime);
            warn Dumper $query;
            $sentences_prime = $db->query($query)->flat;
            $sentences = $sentences_prime and last if @$sentences_prime;
        }
    }
    $sentence = $sentences->[int rand scalar @$sentences];
    push @$poem, $sentence;            
}

print $_, "\n" for @$poem;

#### done.

# functions
sub _connect_db {
    my $filename = shift || ':memory:';
    return DBIx::Simple->connect("dbi:SQLite:dbname=$filename", '', '');
}

sub _handle_args {
    GetOptions(
        'generate_only' => \$generate_only,
        'preload'       => \$preload,
        'corpus=s'      => \$corpus_file,
        'db=s'          => \$db_file,
        'length=i'      => \$length,
        'rhyme=s'       => \$rhyme_str,
        'syllables=s'   => \$syll_str,
        'exact_keyword=s' => \$exact_keyword_str,
        'fuzzy_keyword=s' => \$fuzzy_keyword_str,
    );

    if ( $preload ) {
        die 'Must specify DB for preload option' unless $db_file;
        $db = _connect_db($db_file);
        return;
    }

    $db = _connect_db($db_file);

    $profiled_aref = profile(normalize(slurp($corpus_file)));
    create_db($db) || die 'Failed to create internal database';
    insert_into_db($db, $profiled_aref) || die 'Failed to insert into internal database';

    if ( $generate_only ) {
        say "db saved in $db_file";
        exit;
    }

    my $rhyme_scheme = [split '',  $rhyme_str]; # eg. ABABAB
    my $syll_scheme  = [split ',', $syll_str ]; # eg. 5,7,5 
    my $ex_key_scheme= [split ',', $exact_keyword_str ]; # eg iraq war, perl, china
    my $fz_key_scheme= [split ',', $fuzzy_keyword_str ]; # eg iraq war, perl, china
    
    $length = max($length, scalar @$rhyme_scheme, scalar @$syll_scheme, scalar @$ex_key_scheme, scalar @$fz_key_scheme);

    return {
        length       => $length,
        rhyme_scheme => $rhyme_scheme,
        syll_scheme  => $syll_scheme,
        fuzzy_scheme => $fz_key_scheme,
        exact_scheme => $ex_key_scheme,
    };
}

END {
    $db->disconnect(); # a warning is thrown about active handles, a recognized bug in DBD::SQLite
}
