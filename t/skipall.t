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

my $Test = Test::Builder->create;
$Test->plan(tests => 2);

my $out = '';
my $err = '';
{
    my $tb = Test::More->builder;
    $tb->output(\$out);
    $tb->failure_output(\$err);

    plan 'skip_all';
}

END {
    $Test->is_eq($out, <<OUT);
TAP Version 13
1..0 # SKIP
OUT

    $Test->is_eq($err, "");
}
