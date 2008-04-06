BEGIN {
    if( $ENV{PERL_CORE} ) {
        chdir 't';
        @INC = ('../lib', 'lib');
    }
    else {
        unshift @INC, 't/lib';
    }
}

require MyTestBuilder;
my $Test = MyTestBuilder->create;
$Test->plan(tests => 2);


require Test::Simple;

require Test::Simple::Catch;
my($out, $err) = Test::Simple::Catch::caught();


Test::Simple->import('no_plan');

ok(1, 'foo');


END {
    $Test->core_tap_ok($$out, <<OUT);
ok 1 - foo
1..1
OUT

    $Test->is_eq($$err, <<ERR);
ERR

    # Prevent Test::Simple from exiting with non zero
    exit 0;
}
