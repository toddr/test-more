BEGIN {
    if( $ENV{PERL_CORE} ) {
        chdir 't';
        @INC = ('../lib', 'lib');
    }
    else {
        unshift @INC, 't/lib';
    }
}


# This has to be a require or else the END block below runs before
# Test::Builder's own and the ending diagnostics don't come out right.
require MyTestBuilder;
my $Test = MyTestBuilder->create;
$Test->plan(tests => 2);


package main;

require Test::Simple;

require Test::Simple::Catch;
my($out, $err) = Test::Simple::Catch::caught();
local $ENV{HARNESS_ACTIVE} = 0;

Test::Simple->import(tests => 5);

#line 30
ok(1, 'Foo');
ok(0, 'Bar');

END {
    $Test->core_tap_ok($$out, <<OUT);
1..5
ok 1 - Foo
not ok 2 - Bar
OUT

    $Test->is_eq($$err, <<ERR);
#   Failed test 'Bar'
#   at $0 line 31.
# Looks like you planned 5 tests but only ran 2.
# Looks like you failed 1 test of 2 run.
ERR

    exit 0;
}
