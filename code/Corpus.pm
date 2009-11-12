# who   nate smith
# what  corpus management module
# why   part of senior thesis
# when  Oct 09
# where CS488 Earlham College
use warnings;
use strict;

package Corpus;
use base 'Exporter';

# CPAN modules
use Perl6::Junction 'any';
#use List::Util 'reduce';
use Lingua::EN::Sentence qw/
    get_sentences
    add_acronyms
/;
use Lingua::EN::Syllable;
use Lingua::EN::Hyphenate 'syllables';
use Lingua::EN::Phoneme;
use Lingua::EN::Splitter 'words';
# can't finish implementing the Unapostrophe module as I can't
# syntactically distinguish between possessives and contractions involving
# pronouns. Argh! strip apostrophes for now.  
#use Lingua::EN::Unapostrophe 'unapostrophe';

our @EXPORT_OK = qw/
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

    $string =~ s/^(.*)[^.]$/$1\./;
    $string =~ s/\n//;

    add_acronyms(qw/
        Trans
        A
    /);

    # my brief experiments show that this returns sentences in-order. if this later
    # proves to not be the case, I will have to reimplement this.
    my $list = get_sentences($string);

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
    my $line_no = 0;
    my $words;
    my @last_word_phonemes;
    my $num_syllables;
    for my $sentence ( @$normalized ) {
        # first of probably several sloppy regexes
        $sentence =~ s/'//g;
        $words = words $sentence;

        push @$list, { 
            sentence        => $sentence,
            num_words       => scalar @$words, 
            num_syllables   => _get_syllable_count($words), 
            end_rhyme_sound => _find_rhyme_sound($words->[-1]),
            line_no         => $line_no++,
        };
    }

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

=head _get_syllable_count

    my $count = _get_syllable_count($words_aref);

This is here because reduce { syllable $a + syllable $b } @$words was producing bad results.

Args:
    -array ref of words

Returns:
    -syllable count

=cut
sub _get_syllable_count {
    my $words = shift;

    my $count = 0;
    my $total = 0;

    my $lep = Lingua::EN::Phoneme->new();

    for my $word (@$words) {
        $count = 0;
        my @phons = $lep->phoneme($words);
   
        length == 3 ? $count++ : '' for @phons;
  
        $total += $count && next if $count; 

        # $count was still zero, so we'll fall back
        # to Lingua::EN::Syllable

        $count = $count + syllable($word);

        # could still fall back to Lingua::EN:Hyphenate, but not sure how
        # to check the accuracy of syllable(). Here for later, if needed.
        # syllables method from Lingua::EN::Hyphenate
        #my @syls;
        #for my $word ( @$words ) {
        #    @syls = syllables($word);
        #    $count = $count + scalar @syls;
        #}

        $total += $count;
    }

    return $total;
}

=head2 _find_rhyme_sound

    my $rhyme_sound = _find_rhyme_sound($word);

Args:
    -some word in English

Returns:
    -A string representing the phoneme pattern against which one can check for rhymes

=cut
sub _find_rhyme_sound {
    my $word = shift;

    my $lep = Lingua::EN::Phoneme->new;

    my @phons = $lep->phoneme($word);

    return '' unless @phons;

    my $num_phons = scalar @phons;

    return pop @phons if scalar @phons == any(1,2);

    return join '', @phons[-3,-2,-1] if $phons[-1] eq 'S';

    return join '', @phons[-2,-1];
}

1
