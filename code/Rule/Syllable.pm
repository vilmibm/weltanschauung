package Rule::Syllable;
use base 'Rule';

use strict;
use warnings;

use feature 'switch';

sub new {
    my $class = shift;
    my $self  = {};

    $self->{num_syll} = shift || die 'must pass a syll count';
    $self->{weakness}   = 4;

    bless $self, $class;

    return $self;
}

sub get_clause {
    my $self = shift;

    my $num_syll = $self->{num_syll};

    given ($self->get_weakness()) {
        when (4) { return "(num_syllables = $num_syll)" }
        when ([1..3]) {
            my $range = 4 - $_;
            return "(num_syllables BETWEEN $num_syll-$range AND $num_syll+$range)"
        }
        when (0) { return '(1)' }
    }
}

1;
