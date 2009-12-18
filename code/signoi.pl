#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

my $runs = shift @ARGV;

my $signal;
for (1..$runs) {
    my $poem = `./weltanschauung.pl @ARGV`;
    say $poem;
    print 'Keep? y/[n]:';
    my $answer = <STDIN>;
    $signal++ if $answer =~ /^y/i;
}

say "Kept $signal out of $runs poems.";
say "Signal-to-noise ratio is " . $signal / $runs;
