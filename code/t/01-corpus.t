# who   nate smith
# what  test for corpus module
# when  nov 09
# where cs488 earlham college
# why   part of senior thesis

use lib '..';

use Corpus qw/
    profile
    normalize 
    insert_into_db
/;

use Test::More 'no_plan';

my $trivial_lines = profile('../trivial_corpus');
my $expected_lines = [];
is_deeply($trivial_lines, $expected_lines, 'trivial profile');

my $trivial_normalized = normalize($trivial_lines); 
my $expected_normalized = [];
is_deeply($trivial_normalized, $expected_normalized, 'trivial normalized'); 

my $simple_lines = profile('../simple_corpus');
$expected_lines = [];
is_deeply($simple_lines, $expected_lines, 'simple profiled');
my $simple_normalized = normalize($simple_lines);
$expected_normalized = [];
is_deeply($simple_normalized, $expected_normalized, 'simple normalized');
