#!/usr/bin/perl -w

use strict;
use warnings;

use lib 't/lib';
use Test::More;
use Test::Builder::NoOutput;


sub failing_test {
    my $args = shift;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $ok;
    my $tb = Test::Builder::NoOutput->create;
    {
        local $Test::Builder::Test = $tb;
        $ok = $args->{code}->();
    }

    ok !$ok, "test failed";

    my($pack, $file, $line) = caller;
    $line--;
    for my $ref (\($args->{out}, $args->{err})) {
        $$ref =~ s{\%file}{$file}g;
        $$ref =~ s{\%line}{$line}g;
    }

    is $tb->read('out'), $args->{out}, "  out is correct";
    is $tb->read('err'), $args->{err}, "  err is correct";
}


# Do some true testing
{
    not_ok( 0,              "zero");
    not_ok( "",             "empty string" );
    not_ok( undef,          "undef" );
}


# boolean overloaded object
{
    package False;

    # Test that we look at boolean first over everything else.
    use overload
      "bool" => sub { 0 },
      "0+"   => sub { 1 },
      '""'   => sub { "true" }
    ;

    sub new { bless {}, shift }

    ::not_ok( False->new, "A boolean overloaded false object" );
}


# numerically overloaded object
{
    package Zero;

    use overload
      "0+" => sub { 0 };

    sub new { bless {}, shift }

    ::not_ok( Zero->new, "A numerically overloaded false object" );
}


# Test failure
{
    failing_test {
        code => sub { not_ok(1, "1 is false?") },
        out  => "not ok 1 - 1 is false?\n",
        err  => <<'DIAG',
#   Failed test '1 is false?'
#   at %file line %line.
#          got: 1
#     expected: False
DIAG
    };

    failing_test {
        code => sub { not_ok("0 but true"); },
        out  => "not ok 1\n",
        err  => <<'DIAG',
#   Failed test at %file line %line.
#          got: '0 but true'
#     expected: False
DIAG
    };

    failing_test {
        code => sub { not_ok("False"); },
        out  => "not ok 1\n",
        err  => <<'DIAG',
#   Failed test at %file line %line.
#          got: 'False'
#     expected: False
DIAG
    };
}


# boolean overloaded object
{
    package True;

    # Test that we look at boolean first over everything else.
    use overload
      "bool" => sub { 1 },
      "0+"   => sub { 0 },
      '""'   => sub { "" }
    ;

    sub new { bless {}, shift }

    ::failing_test {
        code => sub { ::not_ok( True->new, "A boolean overloaded true object" ); },
        out  => "not ok 1 - A boolean overloaded true object\n",
        err  => <<'DIAG',
#   Failed test 'A boolean overloaded true object'
#   at %file line %line.
#          got: 0
#     expected: False
DIAG
    };
}

ok !eval q{not_ok(); 1 }, "not_ok with no args";

done_testing(18);
