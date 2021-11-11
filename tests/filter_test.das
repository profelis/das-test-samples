require fio
require rtti
require daslib/strings_boost
require dastest/testing_boost
require dastest/suite
require dastest/fs

[test]
def test_filter(t: T?)
    let path = dir_name(string(get_line_info().fileInfo.name)) |> join_path("filter_data.das")

    var map <- [{ tuple<array<string>; int>[]
        [[auto [{auto[] "a"}], 4]];
        [[auto [{auto[] "aa"}], 2]];
        [[auto [{auto[] "aaa"}], 1]];
        [[auto [{auto[] "ba"}], 1]];
        [[auto [{auto[] "ca"}], 1]]
    }]

    var ctx <- createSuiteCtx()
    var fileCtx <- SuiteFileCtx(ctx)
    fileCtx.indenting = "\t\t"
    for test in map
        unsafe
            t |> run("filter [ \"{join(test._0, "\", \"")}\" ]") <| @(tt: T?)
                ctx.testNames <- test._0
                let res = test_file(path, ctx, fileCtx)
                equal(tt, res, [[SuiteResult total=test._1, passed=test._1]])
