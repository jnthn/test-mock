use Test;
use Test::Mock;

plan 6;

class Yak {
    has $.shaved;
}

class Shaver {
    method shave($yak) {
        ...
    }
}

class YakStore {
    method get-all-yaks() {
        ...
    }
}

class YakShaving {
    has $.yak-store;
    has $.yak-shaver;
    method proccess() {
        for $!yak-store.get-all-yaks() -> $yak {
           unless $yak.shaved {
               $!yak-shaver.shave($yak);
           }
        }
    }
}

my $shaver = mocked(Shaver);
my $store = mocked(YakStore, computing => {
    get-all-yaks => { Yak.new(:!shaved), Yak.new(:shaved), Yak.new(:!shaved) }
});
my $yaktivity = YakShaving.new(
    yak-store => $store,
    yak-shaver => $shaver
);
$yaktivity.proccess();
check-mock($store,
    *.called('get-all-yaks', times => 1)
);
check-mock($shaver,
    *.called('shave', times => 2, with => :($ where { !$^y.shaved })),
    *.never-called('shave', with => :($ where { $^y.shaved }))
);

$shaver = mocked(Shaver);
$store = mocked(YakStore, computing => {
    get-all-yaks => { die "Boom!" }
});
$yaktivity = YakShaving.new(
    yak-store => $store,
    yak-shaver => $shaver
);
throws-like { $yaktivity.proccess() }, X::AdHoc, message => "Boom!";
check-mock($store,
    *.called('get-all-yaks', times => 1)
);
check-mock($shaver,
    *.never-called('shave')
);
