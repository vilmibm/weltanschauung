#!/usr/bin/perl
use strict;
use warnings;

use WWW::Mechanize;

my $mech = WWW::Mechanize->new();
$mech->agent_alias( 'Windows Mozilla' ); # blocked otherwise

my $browse = 'http://www.gutenberg.org/browse/authors/';
my $book_page   = 'http://www.gutenberg.org/etext/';
my $english_books;

for my $letter ('a'..'c') {
    $mech->get($browse.$letter);
    my $content = $mech->content();

    for my $line (split "\n", $content) {
        push @$english_books, $1 if $line =~ m/\/etext\/(\d*).*\(English\)/;   
    }
}

my $num_books = scalar @$english_books;
print "Found $num_books english books\n";

my $corpus = '';
my $file = 'guten_'.time().'.txt';
open my $fh, '>', $file;

my $count = 0;
for my $book (@$english_books) {
    print "Fetching book $count of $num_books\n";
    $count++;
    $mech->get($book_page.$book);
    my $link = $mech->find_link(url_regex=>qr(/files/$book/$book.txt$));
    print "Cannot find plain text, skipping...\n" && next unless $link; 
    
    $mech->get($link->url());

    my $book_text = $mech->content();

    $book_text =~ s/.*\*\*\* START OF THIS PROJECT GUTENBERG EBOOK//s;
    $book_text =~ s/\*\*\* END OF THIS PROJECT GUTENBERG.*$//s;

    $corpus .= $book_text;

    # to prevent overloading memory
    if ( $count % 200 == 0 || $count == $num_books ) {
        print "Dumping to $file...\n";
        print $fh $corpus;
        $corpus = '';
    }

}

close $fh;

END { 
    print $fh $corpus if ($count != $num_books);
    print "Wrote corpus in $file.\n";
}
