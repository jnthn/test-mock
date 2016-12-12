use Test;
use Test::Mock;

plan 4;

class MockMe {
    method m1($a, $b) {
        $a + $b
    }
    method m2(:$y, :$z) {
        $y + $z
    }
}

my $mock = mocked(MockMe, overriding => {
    m1 => -> $a, $b { $a * $b },
    m2 => -> :$y, :$z { $y - $z }
});
is $mock.m1(4, 5), 20, 'Used overriding closure to produce result (positional args)';
is $mock.m2(:4y, :5z), -1, 'Used overriding closure to produce result (named args)';
check-mock $mock,
    *.called('m1'),
    *.called('m2');
