#!/usr/bin/perl
# who   nate smith
# what  wikipedia -> corpus harvester
# when  nov 09
# why   cs488 senior seminar
# where earlham college

=head1 SYNOPSIS

This script harvests text from wikipedia up to a certain number of articles and
from some URL starting point using a naiive, drunk crawling algorithm. It jams the
content it finds into a text file. 

=cut

use warnings;
use strict;
use feature ':5.10';
use Getopt::Long;
use WWW::Mechanize;

my $url          = 'http://en.wikipedia.org/wiki/Special:Random';
my $links_to_hit = 10;
my $corpus  = 'wikipedia_' . localtime() . '.txt';
my $verbose      = 1;

GetOptions(
    'url=s'       => \$url,
    'num_links=i' => \$links_to_hit,
    'corpus=s'    => \$corpus,
    'verbose'     => $verbose
);

open my $corpus_fh, '>', $corpus;
die 'Cannot write to corpus file.' unless -w $corpus_fh;

say "Harvesting $links_to_hit pages from Wikipedia..." if $verbose;

my ($urls, $links_seen, $text);
my $mech = WWW::Mechanize->new();

for (1..$links_to_hit) {
    say "Fetching $url..." if $verbose;
    $mech->get($url);

    $text = $mech->content(format=>'text');
    say "Writing to $corpus..." if $verbose;
    print $corpus_fh $text;

    push @$links_seen, $url unless $url =~ /Special:Random/; # we can see the Special:Random page any number of times.

    say 'Finding next link...' if $verbose;
    $urls = $mech->find_all_links(url_regex => qr(/wiki/\w+$)); # this will exclude anything with '.' or ':'
    while ( $url ~~ @$links_seen ) {
        $url = $urls->[int rand scalar @$urls];
    }
}

close $corpus_fh;
