# who   nate smith
# what  rules module
# when  Oct 09
# why   senior thesis
# where CS488 Earlham College

package Rules;
use base 'Exporter';

@EXPORT_OK = qw/
    rules_parse
    rule_to_query
    query_to_rule
    decompose
/;

=head2 rules_parse
    
    my $rules_aref = rules_parse($user_input);

Args:
    -some user input string

Returns:
    -array ref of list of rules

=cut
sub rules_parse {
    my $input = shift;

    my $rules = [];

    return $rules;
}

=head2

    my $query = rule_to_query($rule);

Args:
    -some rule string

Returns:
    -equivalent query string

=cut
sub rule_to_query {
    my $rule = shift;

    my $query = '';

    return $query;
}

=head2

    my $rule = query_to_rule($query);

Args:
    -some query string

Returns:
    -equivalent rule string

=cut
sub query_to_rule {
    my $query = shift;

    my $rule = '';

    return $rule;
}

=head2 decompose

    my $weakened_rule = decompose($rule);

Args:
    -some rule string

Returns:
    -rule string with some property removed

=cut
sub decompose {
    my $rule = shift;

    return $rule;
}


1
