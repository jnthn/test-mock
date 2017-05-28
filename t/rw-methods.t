use Test;
use lib "lib";
use Test::Mock;

plan 5;

subtest {
	my class C {
		has $.a is rw
	}

	my $mock = mocked(C);

	lives-ok {
		$mock.a = 42
	}

	check-mock $mock,
		*.called: "a", :1times, with => \()
	;

	is $mock.a, 42;
}

subtest {
	my class C {
		has %!a;
		method a($attr) is rw { %!a{$attr} }
	}

	my $mock = mocked(C);

	lives-ok {
		$mock.a("test") = 42
	}

	check-mock $mock,
		*.called: "a", :1times, with => \("test")
	;

	is $mock.a("test"), 42
}

subtest {
	my class C {
		has $.a is rw;
	}

	my $a = 42;
	my $mock = mocked(C,
		returning => {
			a => $a
		}
	);

	is $mock.a, 42;
	lives-ok {
		$mock.a = 13
	}

	check-mock $mock,
		*.called: "a", :2times, with => \()
	;

	is $mock.a, 13
}

subtest {
	my class C {
		has $.a is rw;
	}

	my $mock = mocked(C,
		computing => {
			a => { $ }
		}
	);

	lives-ok {
		$mock.a = 13
	}

	check-mock $mock,
		*.called: "a", :1times, with => \()
	;

	is $mock.a, 13
}

subtest {
	my class C {
		has $.a is rw;
	}

	my $mock = mocked(C,
		overriding => {
			a => -> $index { state %a; %a{$index} }
		}
	);

	lives-ok {
		$mock.a("test") = 13
	}

	check-mock $mock,
		*.called: "a", :1times, with => \("test")
	;

	is $mock.a("test"), 13
}
