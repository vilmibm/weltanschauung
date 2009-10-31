# who   nate smith
# what  corpus management module
# why   part of senior thesis
# when  Oct 09
# where CS488 Earlham College

package corpus;
use base 'Exporter';

@EXPORT_OK = qw/
    normalize
    profile
    insert_into_db
/;

=head2 normalize

    my $normalized_sentences_aref = normalize($corpus_str);

Args:
    -some corpus as a string

Returns:
    -array reference of the corpus split into a list of sentences/sentence fragments

=cut
sub normalize {
    my $string = shift;

    my $list = [];

    return $list;
}

=head2 profile

    my $profiled_aref = profile($normalized_sentences_aref);

Args:
    -some list of sentences and sentence fragments

Returns:
    -An array reference of a list of hrefs containing each sentence and info about it

=cut
sub profile {
    my $normalized = shift;

    my $list = [];
    return $list;
}

=head2 insert_into_db

    my $success = insert_into_db($dbh, $profiles_aref);

Args:
    -database handle
    -An array reference of a list of hrefs containing each sentence and info about it

Returns:
    -0 if unsuccessful, number of rows inserted otherwise.

=cut
sub insert_into_db {
    my $dbh      = shift;
    my $profiles = shift;

    return 0;
}

1
