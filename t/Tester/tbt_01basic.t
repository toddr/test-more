#!/usr/bin/perl

use Test::Builder::Tester tests => 12;
use Test::More;

ok(1,"This is a basic test");

test_out("ok 1 - tested");
ok(1,"tested");
test_test("captured okay on basic");

test_out("ok 1 - tested");
ok(1,"tested");
test_test("captured okay again without changing number");

ok(1,"test unrelated to Test::Builder::Tester");

test_out("ok 1 - one");
test_out("ok 2 - two");
ok(1,"one");
ok(2,"two");
test_test("multiple tests");

test_out("not ok 1 - should fail");
test_err("#     Failed test ($0 at line 28)");
test_err("#          got: 'foo'");
test_err("#     expected: 'bar'");
is("foo","bar","should fail");
test_test("testing failing");


test_out("not ok 1");
test_out("not ok 2");
test_fail(+2);
test_fail(+1);
fail();  fail();
test_test("testing failing on the same line with no name");


test_out("not ok 1 - name");
test_out("not ok 2 - name");
test_fail(+2);
test_fail(+1);
fail("name");  fail("name");
test_test("testing failing on the same line with the same name");


test_out("not ok 1 - name # TODO Something");
test_out("#     Failed (TODO) test ($0 at line 52)");
TODO: { 
    local $TODO = "Something";
    fail("name");
}
test_test("testing failing with todo");


# example in T::B::T POD
test_in_todo(1);
test_out("not ok 1 - failed # TODO My Todo Reason");
test_fail(+6);
test_diag("message");
test_in_todo(0);

TODO: {
  local $TODO = "My Todo Reason";
  fail("failed");
  diag("message");
}

test_test("failed TODO test");


test_out("not ok 1 - foo");
test_fail(+1);
fail("foo");
test_test("failed test after using test_in_todo");


test_out("not ok 1 - foo");
test_fail(+10);
test_diag("foo diag");
test_in_todo(1);
test_out("not ok 2 - bar # TODO Reason");
test_fail(+10);
test_diag("bar diag");
test_in_todo(0);
test_out("not ok 3 - baz");
test_fail(+9);
test_diag("baz diag");
fail("foo");
diag("foo diag");
TODO: {
    local $TODO = "Reason";
    fail("bar");
    diag("bar diag");
}
fail("baz");
diag("baz diag");
test_test("in and out of TODO");


