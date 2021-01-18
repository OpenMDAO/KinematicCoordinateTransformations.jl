Test.@testset "Benchmarks" begin

    include(joinpath(@__DIR__, "..", "perf", "benchmarks.jl"))

    Test.@testset "Code Improvement Benchmarks" begin
        suite, results = run_benchmarks()

        # Let's do some comparisons. What do I want to compare? The time and memory
        # allocations, I guess. First thing to check is that the composed
        # transformation is faster than the sequential.
        println("Composed vs sequential comparison: SteadyRotXTransformation, ConstantLinearMap, ConstantVelocityTransformation")
        r1 = results["composed vs sequential"]
        m_seq = median(r1["sequential"])
        m_com = median(r1["composed"])
        j = judge(m_com, m_seq)
        display(j)
        Test.@test isimprovement(j)

        println("Mutating vs allocating comparison, SteadyRotXTransformation:")
        r21 = results["mutating vs allocating"]["SteadyRotXTransformation"]
        m_mut = median(r21["mutating"])
        m_all = median(r21["allocating"])
        j = judge(m_mut, m_all)
        display(j)
        Test.@test isimprovement(j)

        println("Mutating vs allocating comparison, ConstantLinearMap:")
        r22 = results["mutating vs allocating"]["ConstantLinearMap"]
        m_mut = median(r21["mutating"])
        m_all = median(r21["allocating"])
        j = judge(m_mut, m_all)
        display(j)
        Test.@test isimprovement(j)

        println("Mutating vs allocating comparison, ConstantVelocityTransformation:")
        r22 = results["mutating vs allocating"]["ConstantVelocityTransformation"]
        m_mut = median(r21["mutating"])
        m_all = median(r21["allocating"])
        j = judge(m_mut, m_all)
        display(j)
        Test.@test isimprovement(j)
    end

    # This doesn't work, since `test` runs with --check-bounds=yes, which makes
    # everything slower, so the tests will always show a regression. 
    # Test.@testset "Regression Benchmarks" begin
    #     suite, results = run_benchmarks()

    #     # Now, let's compare the current results to the saved ones.
    #     oldresults = BenchmarkTools.load(resultsfile)[1]
    #     for (keys, trial) in leaves(results)
    #         oldtrial = oldresults[keys]
    #         mnew = median(trial)
    #         mold = median(oldtrial)
    #         j = judge(mnew, mold)
    #         println(keys)
    #         display(j)
    #         Test.@test !isregression(j)
    #     end
    # end

end
