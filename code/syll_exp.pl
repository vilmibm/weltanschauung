use Lingua::EN::Phoneme;
use Lingua::EN::Syllable;
use Lingua::EN::Hyphenate 'syllables';
use feature 'say';

use warnings; use strict;

my $lep = Lingua::EN::Phoneme->new();

my @words = qw/
  poetry
  simpleton
  bread
  knead
  dough
  alfred
  wonton
  wasteful
  gastronomical
  burgess
  dutchess
  duchess
  bear
  boar
  wearable
  bearable
  boring
  greedy
  heady
  ready
  fed
  treading
  ado
/;

for my $word (@words) {
  say join ', ', $lep->phoneme($word);
  say syllable $word;
  say join ', ', syllables $word;
}
