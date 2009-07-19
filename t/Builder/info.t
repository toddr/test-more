#!/usr/bin/perl -w

use strict;
use warnings;

use YAML::Any;
use JSON::Any;

use lib 't/lib';
use Test::More;
use Test::Builder;
use Test::Builder::NoOutput;

my $Test = Test::Builder->new;
my $tb = Test::Builder::NoOutput->create;

# Basic YAML
{
    $tb->info({ have => 23, want => 42 }, {format => "YAML"});
    my $yaml = $tb->read();

    $Test->like( $yaml, qr/^  ---\s*/, "starts with an indented yaml doc" );
    $Test->like( $_, qr/^  /, "  line is indented" ) for split /\n/, $yaml;

    $yaml =~ s/^  //msg;
    is_deeply( Load($yaml), { have => 23, want => 42 }, "YAML round trip" );
}


# Basic JSON
{
    $tb->info({ have => 23, want => 42 }, {format => "JSON"});
    my $json = $tb->read();

    $Test->like( $_, qr/^  /, "  line is indented" ) for split /\n/, $json;

    is_deeply( JSON::Any->Load($json), { have => 23, want => 42 }, "JSON round trip" );
}


$Test->done_testing();
