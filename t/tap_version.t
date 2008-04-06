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

use Test::More;
use Test::Simple::Catch;
my($out, $err) = Test::Simple::Catch::caught();
local $ENV{HARNESS_ACTIVE} = 0;

# Thing to test the tests with
my $Test = Test::Builder->create;
$Test->level(0);
$Test->plan(tests => 10);

my $tb = Test::More->builder;

my $TAP_VERSION = $tb->tap_version;

sub _reset {
    my $builder = shift;

    $builder->current_test(0);

    $builder->{Have_Plan} = 0;
    $builder->{Called_TAP_Version} = 0;

    $tb->use_tap_version_header(undef);
    $tb->no_header(0);
}


sub standard_test {
    plan tests => 2;
    pass();
    pass();

    $tb->_ending;

    _reset($tb);
}


sub test_envelope_ok {
    my($setup, $expect, $name) = @_;

    $setup->();

    $Test->is_eq( $out->read, $expect, $name );
}


test_envelope_ok sub {
    local $ENV{TAP_VERSION};

    standard_test();
}, <<'EXPECT', 'no TAP_VERSION, no TAP envelope';
1..2
ok 1
ok 2
EXPECT


test_envelope_ok sub {
    local $ENV{TAP_VERSION} = 12;

    standard_test();
}, <<'EXPECT', 'TAP_VERSION too low';
1..2
ok 1
ok 2
EXPECT


test_envelope_ok sub {
    local $ENV{TAP_VERSION} = 13;

    standard_test();
}, <<"EXPECT", 'TAP_VERSION right level';
TAP version $TAP_VERSION
1..2
ok 1
ok 2
EXPECT


test_envelope_ok sub {
    local $ENV{TAP_VERSION} = 14;

    standard_test();
}, <<"EXPECT", "TAP_VERSION at a higher level";
TAP version $TAP_VERSION
1..2
ok 1
ok 2
EXPECT


test_envelope_ok sub {
    local $ENV{TAP_VERSION};

    $Test->ok( $tb->use_tap_version_header(1) );

    standard_test();
}, <<"EXPECT", "Forcing TAP version output";
TAP version $TAP_VERSION
1..2
ok 1
ok 2
EXPECT


test_envelope_ok sub {
    local $ENV{TAP_VERSION} = 14;

    $Test->ok( !$tb->use_tap_version_header(0) );

    standard_test();
}, <<"EXPECT", "Diagnostics off, TAP_VERSION high enough";
1..2
ok 1
ok 2
EXPECT


test_envelope_ok sub {
    $tb->use_tap_version_header(1);
    $tb->no_header(1);

    standard_test();
}, <<"EXPECT", "no_header disables TAP version";
ok 1
ok 2
EXPECT


# TAP version with no_plan
test_envelope_ok sub {
    $tb->use_tap_version_header(1);

    plan "no_plan";
    pass();
    pass();
    $tb->_ending;

}, <<"EXPECT", "TAP version with no_plan";
TAP version $TAP_VERSION
ok 1
ok 2
1..2
EXPECT

