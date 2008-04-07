#!/usr/bin/perl -w

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

use Test::Builder;
use TestTestMore;
$MyTest->plan( tests => 8 );

my $Test = Test::More->builder;
$MyTest->isa_ok( $Test, 'Test::Builder' );

$MyTest->is( $Test, Test::More->builder, 'create does not interfere with ->builder' );
$MyTest->is( $Test, Test::Builder->new,  '       does not interfere with ->new' );

{
    my $new_tb  = Test::Builder->create;

    $MyTest->isa_ok( $new_tb,  'Test::Builder' );
    $MyTest->isnt( $Test, $new_tb, 'Test::Builder->create makes a new object' );

    $new_tb->output("some_file");
    END { 1 while unlink "some_file" }

    $new_tb->plan(tests => 1);
    $new_tb->ok(1);
}

$MyTest->pass("Changing output() of new TB doesn't interfere with singleton");

$MyTest->ok( open FILE, "some_file" );
$MyTest->core_tap_ok( join("", <FILE>), <<OUT );
1..1
ok 1
OUT

close FILE;
