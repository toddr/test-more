#!perl -w

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
$Test->plan( tests => 2 );

require Test::Simple::Catch;
my($out, $err) = Test::Simple::Catch::caught();
local $ENV{HARNESS_ACTIVE} = 0;
require Test::Simple;
Test::Simple->import(tests => 5);

#line 35
ok( 1, 'passing' );
ok( 2, 'passing still' );
ok( 3, 'still passing' );
ok( 0, 'oh no!' );
ok( 0, 'damnit' );


END {
    $Test->core_tap_ok($$out, <<OUT);
1..5
ok 1 - passing
ok 2 - passing still
ok 3 - still passing
not ok 4 - oh no!
not ok 5 - damnit
OUT

    $Test->is_eq($$err, <<ERR);
#   Failed test 'oh no!'
#   at $0 line 38.
#   Failed test 'damnit'
#   at $0 line 39.
# Looks like you failed 2 tests of 5.
ERR

    # Prevent Test::Simple from exiting with non zero
    exit 0;
}
