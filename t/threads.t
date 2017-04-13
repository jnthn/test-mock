use Test;
use Test::Mock;

plan 1;

class Foo {
    method lol() { 'rofl' }
}

my $x = mocked(Foo);

await do for ^4 {
    start {
        for ^1000 {
            $x.lol();
        }
    }
}

check-mock($x,
    *.called('lol', times => 4000)
);
