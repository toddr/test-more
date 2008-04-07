package TestTestMore;

# A Test::More for testing Test::Builder
use strict;
use base qw(Test::Builder);

use Test::More ();

use base qw(Exporter);
our $MyTest = TestTestMore->create;
our @EXPORT = qw($MyTest);

sub builder {
    return $MyTest;
}

# Make all Test::More's testing functions available as methods
our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my($function) = $AUTOLOAD =~ m{::([^:]+)$};

    return if $function eq 'DESTROY';

    die "$function is not a function of Test::More" unless
      grep { $function eq $_ } @Test::More::EXPORT;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    local $Test::Builder::Test  = $MyTest;
    no strict 'refs';
    &{"Test::More::".$function}(@_);
}

sub ok   { shift->SUPER::ok(@_) }
sub like { shift->SUPER::like(@_) }

use Symbol;
use TieOut;
my($out_fh, $err_fh) = (gensym, gensym);
my $out = tie *$out_fh, 'TieOut';
my $err = tie *$err_fh, 'TieOut';

sub catch_output {
    my $self = shift;

    $self->output($out_fh);
    $self->failure_output($err_fh);
    $self->todo_output($err_fh);
}

sub caught { return($out, $err) }

sub out {
    $out;
}

sub err {
    $err;
}

sub yaml_diag_is {
    my $self = shift;
    my($yaml_have, $yaml_want, $name) = @_;
    $name ||= 'YAML diagnostics';

    $yaml_have =~ s{^---
                     (.*?)
                     \.\.\.$}{}mx;
    $yaml_have = $1;

    require YAML::Tiny;
    my $have = YAML::Tiny->read_string($yaml_have);
    my $want = YAML::Tiny->read_string($yaml_want);

    return $self->is_deeply( $have, $want, $name );
}

sub core_tap_ok {
    my $self = shift;
    my($have, $want) = @_;

    for my $tap ( \($have, $want) ) {
        _strip_tap_version($tap);
        _strip_tap_meta($tap);
        _strip_tap_done($tap);
    }

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    return $self->is($have, $want);
}

sub _strip_tap_version {
    my $tap = shift;

    $$tap =~ s{^TAP version \d+\n}{};
}

sub _strip_tap_meta {
    my $tap = shift;

    $$tap =~ s{^\s+ --- \n
                   *?
               ^\s+ ... \n
              }{}mx;
}

sub _strip_tap_done {
    my $tap = shift;

    $$tap =~ s{^TAP done\n$}{}m;
}

END {
    $MyTest->_ending
}

1;
