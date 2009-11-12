use strict;
use warnings;

package Lingua::EN::Unapostrophe;

use base 'Exporter';
use Lingua::EN::Splitter 'words';

@EXPORT_OK = qw/
    unapostrophe
/;

my $endings = {
    m  => 'am',
    ll => 'will',
    d  => 'had',
    ve => 'have',
    re => 'are',
};

# s--need to worry about posessive.

my $nonpossesives = [qw/
    she
    he
    it
    there
    that
/]
    
=head1 Lingua::EN::Unapostrophe

eg 

SYNOPSIS

=head2 unapostrophe

    my $string = unapostrophe($string);

Args:
    -$string

Returns 
    -$string, with all apostrophe'd contractions expanded into their two
     word forms.

=cut
sub unapostrophe {
    my $string = shift || return '';

    my $words = words($string);

    for my $word (@$words) {
        $word =~ m/(\d*)'(\d*)/;
        next unless $1 and $2;
        my $root = $1;
        my $ending = $1;
        
    }
}

1;
