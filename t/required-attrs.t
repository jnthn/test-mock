use Test;
use Test::Mock;

plan 2;

class C {
    has $.mock-blocker is required;
    method m() { !!! }
}

my $mock;
lives-ok { $mock = mocked(C) }, 'Can mock object with required attribute';
$mock.m();
check-mock $mock,
    *.called('m', times => 1);
