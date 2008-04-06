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

    $builder->{Have_Plan} = 0;
    $builder->{Called_TAP_Version} = 0;
}


# No TAP_VERSION, no TAP version header
{
    _reset($tb);

    local $ENV{TAP_VERSION};

    plan tests => 2;

    $Test->is_eq( $out->read, <<"END", 'no TAP_VERSION, no TAP version header' );
1..2
END
}


# TAP_VERSION, but too low
{
    _reset($tb);

    local $ENV{TAP_VERSION} = 12;

    plan tests => 2;

    $Test->is_eq( $out->read, <<"END", 'TAP_VERSION too low' );
1..2
END
}


# TAP_VERSION at the right level
{
    _reset($tb);

    local $ENV{TAP_VERSION} = 13;

    plan tests => 2;

    $Test->is_eq( $out->read, <<"END", 'TAP_VERSION right level' );
TAP version $TAP_VERSION
1..2
END
}


# TAP_VERSION at a higher level
{
    _reset($tb);

    local $ENV{TAP_VERSION} = 14;

    plan tests => 2;

    $Test->is_eq( $out->read, <<"END" );
TAP version $TAP_VERSION
1..2
END
}


# Forcing TAP version output
{
    _reset($tb);

    local $ENV{TAP_VERSION};

    $Test->ok( $tb->use_tap_version_header(1) );

    plan tests => 2;

    $Test->is_eq( $out->read, <<"END" );
TAP version $TAP_VERSION
1..2
END
}


# Diagnostics off, TAP_VERSION high enough
{
    _reset($tb);

    local $ENV{TAP_VERSION} = 14;

    $Test->ok( !$tb->use_tap_version_header(0) );

    plan tests => 2;

    $Test->is_eq( $out->read, <<"END" );
1..2
END
}


# no_header disables TAP version
{
    _reset($tb);

    $tb->use_tap_version_header(1);
    $tb->no_header(1);

    plan tests => 2;
    $Test->is_eq( $out->read, "" );

    $tb->no_header(0);
}


# TAP version with no_plan
{
    _reset($tb);

    $tb->use_tap_version_header(1);

    plan "no_plan";
    pass();
    pass();
    $tb->_ending;

    $Test->is_eq( $out->read, <<"END" );
TAP version $TAP_VERSION
ok 1
ok 2
1..2
END

}
