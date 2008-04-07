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

my $Exit_Code;
BEGIN {
    *CORE::GLOBAL::exit = sub { $Exit_Code = shift; };
}


use TestTestMore;
use Test::More;
use TieOut;

use Test::Simple::Catch;
my($out, $err) = Test::Simple::Catch::caught();

if( $] >= 5.005 ) {
    $MyTest->plan(tests => 3);
}
else {
    $MyTest->plan(skip_all => 
          'CORE::GLOBAL::exit, introduced in 5.005, is needed for testing');
}


plan tests => 4;

BAIL_OUT("ROCKS FALL! EVERYONE DIES!");

$MyTest->core_tap_ok( $out->read, <<'OUT' );
1..4
Bail out!  ROCKS FALL! EVERYONE DIES!
OUT

$MyTest->is( $Exit_Code, 255 );

$MyTest->can_ok( "Test::Builder", "BAILOUT" );
