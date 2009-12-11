package Rule::Keyword;
use base 'Rule';

use strict;
use warnings;

use feature 'switch';

sub new {
    my $class = shift;
    my $self  = {};

    $self->{keyword}  = shift || die 'must pass a keyword';
    $self->{type}     = shift || 'fuzzy';
    $self->{weakness} = 11;

    bless $self, $class;

    return $self;
}

sub get_clause {
    my $self = shift;

    my $keyword = $self->{keyword};
    my $type    = $self->{type};

    given ($self->get_weakness()) {
        when (11) {
            continue unless $type eq 'exact';
            return "(sentence LIKE '% $keyword %')";
        }
        when ([1..11]) {
            my $range = 12 - $_;
            # XXX In no universe will this work.
            return "(
                line_no IN (
                    SELECT line_no
                        FROM lines
                        WHERE 
                            line_no BETWEEN line_no+$range AND line_no-$range 
                        AND sentence LIKE '% $keyword %'
                    )
                )
            ";
        }
        when (0) { return '(1)' }
    }
}

1;
