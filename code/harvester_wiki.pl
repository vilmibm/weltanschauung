#!/usr/bin/perl
# who  nate smith
# what wikipedia -> corpus harvester for senior thesis
# when nov 09
# why cs488 senior seminar
# where earlham college

=head1 SYNOPSIS

This script harvests text from wikipedia up to a certain number of articles and
from some URL starting point using a naiive crawling algorithm. It jams the
content it finds into a text file. 

=cut

use warnings;
use strict;
use feature ':5.10';
use Getopt::Long;
use WWW:Mechanize;
use Corpus;

my $url          = 'http://en.wikipedia.org/wiki/Special:Random';
my $links_to_hit = 100;
my $corpus  = 'wikipedia_' . localtime . '.txt';
my $verbose      = 1;

GetOptions(
    'url=s'       => \$url,
    'num_links=i' => \$links_to_hit,
    'corpus=s'    => \$corpus,
    'verbose'     => $verbose
);

open my $corpus_fh, '>', $corpus;

my $links_seen;
my $links_to_visit;
my $mech = WWW::Mechanize->new();

$mech->get($url);




