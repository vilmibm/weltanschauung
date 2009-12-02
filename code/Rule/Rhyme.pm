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
        when (3) { return "(end_rhyme_sound=$sound)"; }
        when (2) { 
            my $weak_sound = $sound;
            $weak_sound =~ s/0/1/ if $sound =~ m/0/;
            $weak_sound =~ s/1/2/ if $sound =~ m/1/;
            $weak_sound =~ s/2/0/ if $sound =~ m/2/;
            return "(end_rhyme_sound=$weak_sound)";
        }
        when (1) { 
            my $weak_sound = $sound;
            $weak_sound =~ s/0/2/ if $sound =~ m/0/;
            $weak_sound =~ s/1/0/ if $sound =~ m/1/;
            $weak_sound =~ s/2/1/ if $sound =~ m/2/;
            return "(end_rhyme_sound=$weak_sound)";
        }
        when (0) { return '(1)' }
    }
}

1;
