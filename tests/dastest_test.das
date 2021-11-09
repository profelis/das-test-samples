
require dastest/testing_boost
require dastest/suite
require dastest/log
require debugapi

[init]
def setup()
    var args <- get_command_line_arguments()
    log::init_log(args)

[test]
def test_deref(t: T?)
    var ctx <- createSuiteFileCtx()
    let res = test_func("deref null", ctx) <| @@(tt: T?)
        var i: int?
        *i = 0

    equal(t, res, [[SuiteResult total=1, errors=1]])


[test]
def test_division_by_zero(t: T?)
    var ctx <- createSuiteFileCtx()
    let res = test_func("division by zero", ctx) <| @@(tt: T?)
        var div = 0
        tt->log("{1 / div}")

    equal(t, res, [[SuiteResult total=1, errors=1]])


[test]
def success_test(t: T?)
    var ctx <- createSuiteFileCtx()
    let res = test_func("success test", ctx) <| @@(tt: T?)
        tt->log("success")

    equal(t, res, [[SuiteResult total=1, passed=1]])


[test]
def skipped_test(t: T?)
    var ctx <- createSuiteFileCtx()
    let res = test_func("skipped test", ctx) <| @@(tt: T?)
        tt->skip("skip now")
        tt->error("this error should be ignored")

    equal(t, res, [[SuiteResult total=1, skipped=1]])


[test]
def failed_test(t: T?)
    var ctx <- createSuiteFileCtx()
    let res = test_func("failed test", ctx) <| @@(tt: T?)
        tt->fail()

    equal(t, res, [[SuiteResult total=1, failed=1]])


[test]
def failed_now_test(t: T?)
    var ctx <- createSuiteFileCtx()
    let res = test_func("fail now test", ctx) <| @@(tt: T?)
        tt->failNow()
        panic("this panic should be skipped")

    equal(t, res, [[SuiteResult total=1, failed=1]])


[test]
def strict_equal_test(t: T?)
    var ctx <- createSuiteFileCtx()
    let res = test_func("strict equal test", ctx) <| @@(tt: T?)
        strictEqual(tt, 1, 2)
        tt->run("unreaceable test") <| @(tt: T?)
            pass

    equal(t, res, [[SuiteResult total=1, failed=1]])


[test]
def mixed_tests(t: T?)
    var ctx <- createSuiteFileCtx()

    // 1 error
    var res = test_func("exception test", ctx) <| @@(tt: T?)
        var i: int?
        *i = 0

    // 1 success
    res += test_func("empty test", ctx) <| @@(tt: T?)
        pass

    // 1 failed now
    res += test_func("fail now test", ctx) <| @@(tt: T?)
        tt->failNow()
        panic("this panic should be skipped")

    // 1 skipped
    res += test_func("skipped test", ctx) <| @@(tt: T?)
        tt->skip("skip now")
        panic("this panic should be skipped")

    // 1 failed
    res += test_func("fail now test", ctx) <| @@(tt: T?)
        tt->fail()

    // 1 passed
    res += test_func("success test", ctx) <| @@(tt: T?)
        equal(tt, 1, 1)

    equal(t, res, [[SuiteResult total=6, errors=1, failed=2, skipped=1, passed=2]])