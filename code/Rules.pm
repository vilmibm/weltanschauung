# who   nate smith
# what  rules module
# when  Oct 09
# why   senior thesis
# where CS488 Earlham College

package Rules;
use base 'Exporter';

use warnings;
use strict;

use feature 'switch';

our @EXPORT_OK = qw/
    rules_parse
    rule_to_query
    query_to_rule
    diminish
/;

=head2 rules_parse
    
    my $rules_aref = rules_parse($rules_href);

Args:
    -database (DBIx::Simple) handle
    -rules_href derived from user input (or defaults)

Returns:
    -array ref of list of rule hashes

=cut
sub rules_parse {
    my $db    = shift || die 'No db handle passed';
    my $input = shift || die 'No input hash passed';

    my $length       = $input->{'length'    };
    my $rhyme_scheme = $input->{rhyme_scheme}; # list of letters
    my $syll_scheme  = $input->{syll_scheme };
    my $rules = [];

    my ($rhyme_href, $rand_sound); # hash of letter->sound (string)
    for my $letter ( @$rhyme_scheme ) {
        unless (exists $rhyme_href->{$letter}) {
            $rand_sound = _random_rhyme_sound($db) 
                while $rand_sound ~~ values %$rhyme_href; # find unused sound
            $rhyme_href->{$letter} = _random_rhyme_sound($db) 
        }
    }

    my ($rule_set, $rhyme_letter, $end_rhyme_sound, $num_syllables);
    for my $index (0 .. $length - 1) { # come up with rule list for this line of poem
        undef $num_syllables; undef $end_rhyme_sound;

        $rule_set = {};

        $end_rhyme_sound = $rhyme_href->{$rhyme_scheme->[$index % (scalar @$rhyme_scheme)]}
            if scalar @$rhyme_scheme;
        $num_syllables   = $syll_scheme->[$index % (scalar @$syll_scheme)]
            if scalar @$syll_scheme;
       
        $rule_set->{end_rhyme_sound} = $end_rhyme_sound if $end_rhyme_sound; 
        $rule_set->{num_syllables}   = $num_syllables   if $num_syllables;

        push @$rules, $rule_set;
    }

    return $rules;
}

=head2 diminish

    my $diminished_rule = diminish($rule);

Args:
    -some rule hash

Returns:
    -rule hash with some key either removed or liberalized

=cut
sub diminish {
    my $rule = shift;

    my $rule_to_diminish = (keys %$rule)[int rand scalar keys %$rule];

    # switch structure to accomodate future, more complex rules
    # XXX for now, it's performing the trivial operation delete $rule->{$rule_to_diminish}
    given ($rule_to_diminish) {
        when ('end_rhyme_sound') {
            delete $rule->{'end_rhyme_sound'}; # harsh, I know.
        }
        when ('num_syllables')   { 
            # XXX This will get complex; I'm going to make this rule range-based, not scalar based.
            delete $rule->{'num_syllables'};
        }
    }

    return $rule;
}

=head2 _random_rhyme_sound

    my $rhyme_sound = _random_rhyme_sound($dbh);

Args:
    -database (DBIx::Simple) handle
Returns:
    -Random rhyme sound from DB in string form

=cut

sub _random_rhyme_sound {
    my $db = shift;

    my $sounds_aref = $db->iquery('SELECT end_rhyme_sound FROM lines')->flat;

    return $sounds_aref->[int rand (scalar @$sounds_aref)];
}

1
