package MyTestBuilder;

use strict;
use base qw(Test::Builder);

sub core_tap_ok {
    my $self = shift;
    my($have, $want) = @_;

    for my $tap ( \($have, $want) ) {
        _strip_tap_version($tap);
        _strip_tap_meta($tap);
    }

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    return $self->is_eq($have, $want);
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

1;
