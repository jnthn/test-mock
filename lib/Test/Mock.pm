use Test;
use OO::Monitors;

monitor Test::Mock::Log {
    has @!log-entries;

    method log-method-call($name, $capture) {
        @!log-entries.push($%( :$name, :$capture ));
    }

    method called($name, :$times, :$with) {
        # Extract calls of the matching name.
        my @calls = @!log-entries.grep({ .<name> eq $name });

        # If we've an argument filter, apply it; we smart-match
        # everything but captures, which we eqv.
        my $with-args-note = "";
        if defined($with) {
            if $with ~~ Capture {
                @calls .= grep({ .<capture> eqv $with });
            }
            else {
                @calls .= grep({ .<capture> ~~ $with });
            }
            $with-args-note = " with arguments matching $with.perl()";
        }

        # Enforce times parameter, if given.
        if defined($times) {
            my $times-msg =
                $times == 0 ?? "never called $name" !!
                $times == 1 ?? "called $name 1 time" !!
                               "called $name $times times";
            is +@calls, $times, "$times-msg$with-args-note";
        }
        else {
            ok ?@calls, "called $name$with-args-note";
        }
    }

    method never-called($name, :$with) {
        self.called($name, times => 0, :$with);
    }
};

module Test::Mock {
    sub mocked($type, :%returning, :%computing, :%overriding) is export {
        # Generate a subclass that logs each method call.
        my %already-seen;
        my $mocker := Metamodel::ClassHOW.new_type();
        $mocker.HOW.add_parent($mocker, $type.WHAT);
        for $type.^mro() -> $p {
            last unless $p.^parents(:local);
            for $p.^methods(:local) -> $m {
                unless %already-seen{$m.name} {
                    $mocker.HOW.add_method($mocker, $m.name, method (|c) {
                        self.'!mock-log'().log-method-call($m.name, c);
                        if %overriding{$m.name} -> $override {
                            $override(|c)
                        }
                        elsif %computing{$m.name} -> $compute {
                            $compute()
                        }
                        elsif %returning{$m.name} ~~ Iterable {
                            @(%returning{$m.name})
                        }
                        else {
                            %returning{$m.name}
                        }
                    });
                    %already-seen{$m.name} = True;
                }
            }
        }

        # Create a log and add a method to access it.
        my $log := Test::Mock::Log.new();
        $mocker.HOW.add_method($mocker, '!mock-log', method { $log });

        # Return a mock object; use use CREATE to bypass construction logic
        # of the real object, since we won't use any of its state anyway
        my $mocked = $mocker.HOW.compose($mocker);
        $mocked.CREATE
    }

    sub check-mock($mock, *@checker) is export {
        .($mock.'!mock-log'()) for @checker;
    }
}
