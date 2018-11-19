use Test;
use Test::Mock;
use lib $*PROGRAM.parent;
use TestMulti;

plan 2;

my $mock = mocked(MockMe, returning => { mmm => 42 });
is $mock.mmm(1), 42, 'Can mock a multi-method (1)';
is $mock.mmm(1, 2), 42, 'Can mock a multi-method (2)';
