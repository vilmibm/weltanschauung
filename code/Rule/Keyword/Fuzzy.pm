package Rule::Keyword::Fuzzy;
use base 'Rule';

use strict;
use warnings;

use feature 'switch';

sub new {
    my $class = shift;
    my $self  = {};

    $self->{keyword}  = shift || die 'must pass a keyword';
    $self->{weakness} = 10;

    bless $self, $class;

    return $self;
}

sub get_clause {
    my $self = shift;

    my $keyword = $self->{keyword};

    given ($self->get_weakness()) {
        when (1..10) {
            my $range = 11 - $_;
            return "(line_no in (SELECT line_no+$range, line_no-$range FROM lines WHERE sentence LIKE '%$keyword%'))";
        }
        when (0) { return '(1)' }
    }
}

1;
