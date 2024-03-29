
require dastest/testing_boost
require dastest/suite
require dastest/log


[init] def setup { log::init_log(); }


def file_ctx()
    var ctx <- createSuiteCtx()
    var res <- FileCtx(ctx)
    delete ctx
    res.stackOnRecover = false
    res.indenting = "\t"
    return <- res


[test]
def test_deref(t: T?)
    var ctx <- file_ctx()
    ctx.expectFailure = true
    let res = test_func("deref null", ctx) <| @@(tt: T?)
        var i: int?
        *i = 0

    equal(t, res, [[SuiteResult total=1, errors=1]])


[test]
def test_division_by_zero(t: T?)
    var ctx <- file_ctx()
    ctx.expectFailure = true
    let res = test_func("division by zero", ctx) <| @@(tt: T?)
        var div = 0
        tt->log("{1 / div}")

    equal(t, res, [[SuiteResult total=1, errors=1]])


[test]
def success_test(t: T?)
    var ctx <- file_ctx()
    let res = test_func("success test", ctx) <| @@(tt: T?)
        tt->log("success")

    equal(t, res, [[SuiteResult total=1, passed=1]])


[test]
def skipped_test(t: T?)
    var ctx <- file_ctx()
    let res = test_func("skipped test", ctx) <| @@(tt: T?)
        tt->skip("skip now")
        tt->error("this error should be ignored")

    equal(t, res, [[SuiteResult total=1, skipped=1]])


[test]
def failed_test(t: T?)
    var ctx <- file_ctx()
    ctx.expectFailure = true
    let res = test_func("failed test", ctx) <| @@(tt: T?)
        tt->fail()

    equal(t, res, [[SuiteResult total=1, failed=1]])


[test]
def failed_now_test(t: T?)
    var ctx <- file_ctx()
    ctx.expectFailure = true
    let res = test_func("fail now test", ctx) <| @@(tt: T?)
        tt->failNow()
        panic("this panic should be skipped")

    equal(t, res, [[SuiteResult total=1, failed=1]])


[test]
def strict_equal_test(t: T?)
    var ctx <- file_ctx()
    ctx.expectFailure = true
    let res = test_func("strict equal test", ctx) <| @@(tt: T?)
        strictEqual(tt, 1, 2)
        tt |> run("unreaceable test") <| @(tt: T?)
            pass

    equal(t, res, [[SuiteResult total=1, failed=1]])


[test]
def panic_test(t: T?)
    var ctx <- file_ctx()
    ctx.expectFailure = true
    let res = test_func("expect panic", ctx) <| @@(tt: T?)
        panic("panic")

    equal(t, res, [[SuiteResult total=1, errors=1]])


[test]
def recover_test(t: T?)
    var ctx <- file_ctx()
    let res = test_func("catch panic", ctx) <| @@(tt: T?)
        var recovered = false
        try
            panic("panic")
        recover
            recovered = true
        tt |> success(recovered)

    equal(t, res, [[SuiteResult total=1, passed=1]])


[test]
def mixed_tests(t: T?)
    var ctx <- file_ctx()

    // 1 error
    var res: SuiteResult
    ctx |> expect_failure <| $
        res += test_func("exception test", ctx) <| @@(tt: T?)
            var i: int?
            *i = 0

    // 1 success
    res += test_func("empty test", ctx) <| @@(tt: T?)
        pass

    // 1 failed now
    ctx |> expect_failure <| $
        res += test_func("fail now test", ctx) <| @@(tt: T?)
            tt->failNow()
            panic("this panic should be skipped")

    // 1 skipped
    res += test_func("skipped test", ctx) <| @@(tt: T?)
        tt->skip("skip now")
        panic("this panic should be skipped")

    // 1 failed
    ctx |> expect_failure <| $
        res += test_func("fail now test", ctx) <| @@(tt: T?)
            tt->fail()

    // 1 passed
    res += test_func("success test", ctx) <| @@(tt: T?)
        equal(tt, 1, 1)

    equal(t, res, [[SuiteResult total=6, errors=1, failed=2, skipped=1, passed=2]])


def expect_failure(var ctx: FileCtx; blk)
    ctx.expectFailure = true
    blk |> invoke()
    ctx.expectFailure = false
