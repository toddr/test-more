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


# This has to be a require or else the END block below runs before
# Test::Builder's own and the ending diagnostics don't come out right.
require TestTestMore;
my $MyTest = TestTestMore->builder;
$MyTest->plan(tests => 2);


require Test::Simple;
Test::Simple->import(tests => 1);
ok(1);
ok(1);
ok(1);

END {
    $MyTest->core_tap_ok($$out, <<OUT);
1..1
ok 1
ok 2
ok 3
OUT

    $MyTest->is($$err, <<ERR);
# Looks like you planned 1 test but ran 2 extra.
ERR

    # Prevent Test::Simple from existing with non-zero
    exit 0;
}
