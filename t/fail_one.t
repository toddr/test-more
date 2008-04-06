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

require MyTestBuilder;
my $Test = MyTestBuilder->create;
$Test->plan(tests => 2);


require Test::Simple::Catch;
my($out, $err) = Test::Simple::Catch::caught();
local $ENV{HARNESS_ACTIVE} = 0;

require Test::Simple;
Test::Simple->import(tests => 1);

#line 45
ok(0);

END {
    $Test->core_tap_ok($$out, <<OUT);
1..1
not ok 1
OUT

    $Test->is_eq($$err, <<ERR) || print $$err;
#   Failed test at $0 line 45.
# Looks like you failed 1 test of 1.
ERR

    # Prevent Test::Simple from existing with non-zero
    exit 0;
}
