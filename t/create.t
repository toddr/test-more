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

use Test::More tests => 8;
use Test::Builder;
use MyTestBuilder;
{
    no warnings 'once';
    *Test::Builder::core_tap_ok = \&MyTestBuilder::core_tap_ok;
}

my $Test = Test::More->builder;
isa_ok $Test, 'Test::Builder';

is $Test, Test::More->builder, 'create does not interfere with ->builder';
is $Test, Test::Builder->new,  '       does not interfere with ->new';

{
    my $new_tb  = Test::Builder->create;

    isa_ok $new_tb,  'Test::Builder';
    isnt $Test, $new_tb, 'Test::Builder->create makes a new object';

    $new_tb->output("some_file");
    END { 1 while unlink "some_file" }

    $new_tb->plan(tests => 1);
    $new_tb->ok(1);
}

pass("Changing output() of new TB doesn't interfere with singleton");

ok open FILE, "some_file";
$Test->core_tap_ok( join("", <FILE>), <<OUT );
1..1
ok 1
OUT

close FILE;
