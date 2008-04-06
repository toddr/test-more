#!/usr/bin/perl -w

BEGIN {
    if( $ENV{PERL_CORE} ) {
        chdir 't';
        @INC = ('../lib', 'lib');
    }
    else {
        unshift @INC, 't/lib';
    }
}

use strict;

require Test::Simple::Catch;
my($out, $err) = Test::Simple::Catch::caught();

# Can't use Test.pm, that's a 5.005 thing.
package My::Test;

# This has to be a require or else the END block below runs before
# Test::Builder's own and the ending diagnostics don't come out right.
require MyTestBuilder;
my $Test = MyTestBuilder->create;
$Test->plan(tests => 2);

sub is { $Test->is_eq(@_) }


package main;

require Test::Simple;
Test::Simple->import(tests => 1);
ok(1);
ok(1);
ok(1);

END {
    $Test->core_tap_ok($$out, <<OUT);
1..1
ok 1
ok 2
ok 3
OUT

    My::Test::is($$err, <<ERR);
# Looks like you planned 1 test but ran 2 extra.
ERR

    # Prevent Test::Simple from existing with non-zero
    exit 0;
}
