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
    };

    bless($self, $class);

    return $self;
}

sub get_weakness {
    my $self = shift;
    return $self->{weakness};
}

sub weaken {
    my $self = shift;
    $self->{weakness} = $self->get_weakness() - 1 unless $self->get_weakness() == 0;
}

# functions that will be overwritten in subclasses
sub get_clause {
    my $self = shift;
    given ($self->get_weakness()) {
        when (0) { return '(1)' }
    }
}

1;
