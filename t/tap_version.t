#!/usr/bin/perl -w

# Test we print TAP Version just in time.

use strict;
use warnings;

use lib 't/lib';
use Test::Builder::NoOutput;
use Test::More;

# no plan
{
    my $tb = Test::Builder::NoOutput->create;
    $tb->ok(1);
    $tb->plan( "no_plan" );
    $tb->_ending;

    is $tb->read, <<OUT;
TAP Version 13
ok 1
1..1
OUT

}


# regular plan
{
    my $tb = Test::Builder::NoOutput->create;
    $tb->plan( tests => 1 );
    $tb->ok(1);

    is $tb->read, <<OUT;
TAP Version 13
1..1
ok 1
OUT
}


# subtest with no previous tests
{
    my $tb = Test::Builder::NoOutput->create;
    $tb->subtest( "first subtest" => sub {
        my $child = $tb->{Child};
        $child->ok(1);
        $child->plan( "no_plan" );
    });
    $tb->done_testing(1);

    is $tb->read, <<OUT;
TAP Version 13
    TAP Version 13
    ok 1
    1..1
ok 1 - first subtest
1..1
OUT
}


# no headers == no version
{
    my $tb = Test::Builder::NoOutput->create;
    $tb->no_header(1);
    $tb->ok(1);

    is $tb->read, <<OUT;
ok 1
OUT
}


# don't give a version if the current test is not 1
{
    my $tb = Test::Builder::NoOutput->create;
    $tb->current_test(4);
    $tb->ok(1);

    is $tb->read, <<OUT;
ok 5
OUT
}


done_testing();
