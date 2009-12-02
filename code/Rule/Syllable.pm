package Rule::Syllable;
use base 'Rule';

use strict;
use warnings;

use feature 'switch';

sub new {
    my $self = SUPER::new();

    $self->{num_syll} = shift || die 'must pass a syll count';
    $self->{weaken}   = 3;

    return $self;
}

sub get_clause {
    my $self = shift;

    my $num_syll = $self->{num_syll};

    given ($self->get_weakness()) {
        when (3) { return "(num_syllables IN ($num_syll)               )" }
        when (2) { return "(num_syllables IN ($num_syll-1, $num_syll+1))" }
        when (1) { return "(num_syllables IN ($num_syll-2, $num_syll+2))" }
        when (0) { return '(1)' }
    }
}

1;
