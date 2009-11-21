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

my $urls;
my $links_seen;
my $mech = WWW::Mechanize->new();

for (1..$links_to_hit) {
    print $corpus_fh, `w3m $url -dump`;
    push @$links_seen, $url unless $url =~ /Random/; # we can see the Special:Random page any number of times.

    $mech->get($url);
    $urls = $mech->find_all_links(url_regex => qr//); # XXX exclude menu, footer links. hardcode?

    $url = $urls->[int rand scalar @$urls];
}

close $corpus_fh;
