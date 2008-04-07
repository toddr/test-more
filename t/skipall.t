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

# Can't use Test.pm, that's a 5.005 thing.
use TestTestMore;
$MyTest->plan( tests => 2 );


package main;
require Test::More;

require Test::Simple::Catch;
my($out, $err) = Test::Simple::Catch::caught();

Test::More->import('skip_all');


END {
    $MyTest->core_tap_ok($$out, "1..0\n");
    $MyTest->is_eq($$err, "");
}
