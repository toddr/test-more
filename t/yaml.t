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

use Test::More 'no_plan';
use Test::Simple::Catch;
my($out, $err) = Test::Simple::Catch::caught();
local $ENV{HARNESS_ACTIVE} = 0;

# Thing to test the tests with
my $Test = Test::Builder->create;
$Test->level(0);

my $tm = Test::More->builder;


# Turn on YAML diagnostics.
{
    $Test->ok( $tm->use_yaml_diagnostics(1),    "YAML diagnostics on" );
    $Test->ok( !$tm->no_stderr_diagnostics(0),  "STDERR diagnostics off" );
}


# Fail
{
    is( 23, 42 );
}
