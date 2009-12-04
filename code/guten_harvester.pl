use strict;
use warnings;

use WWW::Mechanize;

my $mech = WWW::Mechanize->new();
$mech->agent_alias( 'Windows Mozilla' ); # blocked otherwise

my $browse = 'http://www.gutenberg.org/browse/authors/';
my $book_page   = 'http://www.gutenberg.org/etext/';
my $english_books;

for my $letter ('a'..'z') {
    $mech->get($browse.$letter);
    my $content = $mech->content();

    for my $line (split "\n", $content) {
        push @$english_books, $1 if $line =~ m/\/etext\/(\d*).*\(English\)/;   
    }
}

my $corpus = '';

for my $book (@$english_books) {
    $mech->get($book_page.$book);
    $mech->follow_link(url_regex=>qr(/files/$book/$book.txt$));

    my $book_text = $mech->content();

    $book_text =~ s/.*\*\*\* START OF THIS PROJECT GUTENBERG EBOOK//s;
    $book_text =~ s/\*\*\* END OF THIS PROJECT GUTENBERG.*$//s;

    $corpus .= $book_text;

    last;
}

my $file = 'guten_'.time().'.txt';
open my $fh, '>', $file;
print $fh $corpus;
