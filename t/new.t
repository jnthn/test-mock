use Test;
use Test::Mock;

# This test covers a bug where you could not mock the `new` method.

my $m = mocked(Proc::Async, computing => {
    new => { $m },
    start => { start { Proc.new(:0exitcode) } }
});

my $p = $m.new('perl6', '-e', 'say 42');
my $result = await $p.start();

isa-ok $result, Proc, 'Correctly got computed value from mocked start method';
is $result.exitcode, 0, 'Corrected fake exit code';

check-mock $m,
    *.called('new', with => \('perl6', '-e', 'say 42')),
    *.called('start', with => \());

done-testing;
