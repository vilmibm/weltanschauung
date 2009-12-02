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

use Rule::Syllable;
# XXX use Rule::Rhyme;

our @EXPORT_OK = qw/
    rules_parse
    rule_set_to_query
    weaken_rule_set
/;

my $QUERY        = 'SELECT sentence FROM lines WHERE';

=head2 rules_parse
    
    my $rule_sets_aref = rules_parse($db, $rules_href);

Args:
    -database (DBIx::Simple) handle
    -rules_href derived from user input (or defaults)

Returns:
    -array ref of list of rule_sets (which are in turn refs of lists of rule objs)

=cut
sub rules_parse {
    my $db    = shift || die 'No db handle passed';
    my $input = shift || die 'No input hash passed';

    my $length       = $input->{'length'    };
    my $rhyme_scheme = $input->{rhyme_scheme}; # list of letters
    my $syll_scheme  = $input->{syll_scheme };
    my $rule_sets = [];

    my ($rhyme_href, $rand_sound); # hash of letter->sound (string)
    for my $letter ( @$rhyme_scheme ) {
        unless (exists $rhyme_href->{$letter}) {
            $rand_sound = _random_rhyme_sound($db) 
                while $rand_sound ~~ values %$rhyme_href; # find unused sound
            $rhyme_href->{$letter} = _random_rhyme_sound($db) 
        }
    }

    # at this point we have the information needed to build this structure:
    # rule_sets = [
    #   [RuleObj, RuleObj, RuleObj,...], # a rule set
    #   [RuleObj, RuleObj, RuleObj,...],
    #   [RuleObj, RuleObj, RuleObj,...]
    # ]

    my ($rule_set, $rhyme_letter, $end_rhyme_sound, $num_syllables);
    for my $index (0 .. $length - 1) { # come up with rule_set for this line of poem
        undef $num_syllables; undef $end_rhyme_sound;
        
        $rule_set = [];
        
        $end_rhyme_sound = $rhyme_href->{$rhyme_scheme->[$index % (scalar @$rhyme_scheme)]}
            if scalar @$rhyme_scheme;
        $num_syllables   = $syll_scheme->[$index % (scalar @$syll_scheme)]
            if scalar @$syll_scheme;

# XXX   push @$rule_set,    Rule::Rhyme->new($end_rhyme_sound) if $end_rhyme_sound;
        push @$rule_set, Rule::Syllable->new($num_syllables  ) if $num_syllables;

        push @$rule_sets, $rule_set;
    }

    return $rule_sets;
}
=head2

    my $query = rule_set_to_query($rule_set);

Args:
    -some list of rule objects
Returns:
    -equivalent query string

=cut

sub rule_set_to_query {
    my $rule_set = shift;
    my $query    = $QUERY;
    
    my @clauses;
    push @clauses, $_->get_clause() for @$rule_set;

    $query .= join 'AND', @clauses;

    return $query;
}

=head2 weaken_rule_set

    my $weakened_rule_set = weaken_rule_set($rule_set);

Args:
    -some list of rule objects

Returns:
    -same list with some random rule object's weaken called

=cut
sub weaken_rule_set {
    my $rule_set = shift;
    
    $rule_set->[int rand scalar @$rule_set]->weaken();

    return $rule_set;
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
