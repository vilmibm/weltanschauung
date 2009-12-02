package Rule::Rhyme;
use base 'Rule';

use strict;
use warnings;

use feature 'switch';

sub new {
    my $class = shift;
    my $self  = {};

    $self->{sound}      = shift || die 'must pass a sound count';
    $self->{weakness}   = 3; # XXX

    bless $self, $class;

    return $self;
}

sub get_clause {
    my $self = shift;

    my $sound = $self->{sound};

    given ($self->get_weakness()) {
        when (3) { return '(1)' }
        when (2) { return '(1)' }
        when (1) { return '(1)' }
        when (0) { return '(1)' }
    }
}

1;
