# who   nate smith
# what  Rule.pm
# why   object package for senior sem
# where cs488 earlham college
# when  Dec 09
package Rule;

use strict;
use warnings;
use feature 'switch';

sub new {
    my $class = shift;
    my $self  = {
        weakness  => 0,
        bind_vars => {}
    };

    bless($self, $class);

    return $self;
}

sub get_weakness {
    my $self = shift;
    return $self->{weakness};
}

sub get_bind_vars {
    my $self = shift;
    return $self->{bind_vars};
}

# functions that will be overwritten in subclasses
# They are here as a guide
sub get_clause {
    my $self = shift;
    given ($self->get_weakness()) {
        when (0) { return '(1)' }
    }
}

sub weaken {
    my $self = shift;
    $self->{weaken} = $self->get_weakness() - 1 unless $self->get_weakness() == 0;
    # do something with bind_vars
}


1;
