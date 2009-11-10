use Lingua::EN::Phoneme;
use Lingua::EN::Syllable;
use Lingua::EN::Hyphenate 'syllables';
use feature 'say';

use warnings; use strict;

my $lep = Lingua::EN::Phoneme->new();

my @words = qw/
    simpleton
    wonton
    gastronomical
    burgess
    dutchess
    antidisestablishment
    antidote
    wonka
    joomla
    frankfurter
    hamburg
    josephat
    frankenstein
    borges
    borgs
    neither
/;

for my $word (@words) {
  say join ', ', $lep->phoneme($word);
  say syllable $word;
  say join ', ', syllables $word;
}
