using BenchmarkTools
using KinematicCoordinateTransformations

import Random
import StaticArrays

const paramsfile = joinpath(@__DIR__, "params.json")
const resultsfile = joinpath(@__DIR__, "results.json")

function get_test_input(N)
    T = Float64
    X = rand(T, (3, N))
    V = rand(T, (3, N))
    A = rand(T, (3, N))
    J = rand(T, (3, N))

    return X, V, A, J
end

function sequential_no_splatting(trans1, trans2, trans3, t, X0, V0, A0, J0)
    X1, V1, A1, J1 = trans1(t, X0, V0, A0, J0)
    X2, V2, A2, J2 = trans2(t, X1, V1, A1, J1)
    X3, V3, A3, J3 = trans3(t, X2, V2, A2, J2)
    return X3, V3, A3, J3
end

function run_benchmarks(; N=100, load_params=true)

    # Seed the random number generator to get consistent input.
    Random.seed!(1)

    t0 = 2.0
    ω = 2*pi
    θ = 5.0*pi/180.0
    trans1 = SteadyRotXTransformation(t0, ω, θ)

    M2 = StaticArrays.@SMatrix [8.0 1.0 3.0;
                                3.0 6.0 9.0;
                                4.0 7.0 10.0]
    trans2 = ConstantLinearMap(M2)

    t0 = 2.5
    x0 = StaticArrays.SVector(1.0, 2.0, 3.0)
    v = StaticArrays.SVector(2.0, 3.0, 4.0)
    trans3 = ConstantVelocityTransformation(1.0, x0, v)

    t = 3.0
    trans321 = compose(t, trans3, compose(t, trans2, trans1))

    X, V, A, J = get_test_input(N)

    X_new = similar(X)
    V_new = similar(V)
    A_new = similar(A)
    J_new = similar(J)

    suite = BenchmarkGroup()

    s1 = suite["composed vs sequential"] = BenchmarkGroup()
    s1["sequential"] = @benchmarkable $trans3($t, $trans2($t, $trans1($t, $X, $V, $A, $J)...)...)
    s1["sequential_no_splatting"] = @benchmarkable sequential_no_splatting($trans1, $trans2, $trans3, $t, $X, $V, $A, $J)
    s1["composed"] = @benchmarkable $trans321($t, $X, $V, $A, $J)

    s2 = suite["mutating vs allocating"] = BenchmarkGroup()

    s21 = s2["SteadyRotXTransformation"] = BenchmarkGroup()
    s21["allocating"] = @benchmarkable $trans1($t, $X, $V, $A, $J)
    s21["mutating"] = @benchmarkable transform!($X_new, $V_new, $A_new, $J_new, $trans1, $t, $X, $V, $A, $J)

    s22 = s2["ConstantLinearMap"] = BenchmarkGroup()
    s22["allocating"] = @benchmarkable $trans2($t, $X, $V, $A, $J)
    s22["mutating"] = @benchmarkable transform!($X_new, $V_new, $A_new, $J_new, $trans2, $t, $X, $V, $A, $J)

    s23 = s2["ConstantVelocityTransformation"] = BenchmarkGroup()
    s23["allocating"] = @benchmarkable $trans3($t, $X, $V, $A, $J)
    s23["mutating"] = @benchmarkable transform!($X_new, $V_new, $A_new, $J_new, $trans3, $t, $X, $V, $A, $J)

    s24 = s2["composed"] = BenchmarkGroup()
    s24["allocating"] = @benchmarkable $trans321($t, $X, $V, $A, $J)
    s24["mutating"] = @benchmarkable transform!($X_new, $V_new, $A_new, $J_new, $trans321, $t, $X, $V, $A, $J)

    if load_params && isfile(paramsfile)
        # Load the benchmark parameters.
        # https://github.com/JuliaCI/BenchmarkTools.jl/blob/master/doc/manual.md#caching-parameters
        loadparams!(suite, BenchmarkTools.load(paramsfile)[1])

        # Also need to warmup the benchmarks to get rid of the JIT overhead
        # (when not using tune!):
        # https://discourse.julialang.org/t/benchmarktools-theory-and-practice/5728
        warmup(suite, verbose=false)
    else
        tune!(suite, verbose=false)
    end

    results = run(suite, verbose=false)

    return suite, results
end

function save_benchmarks()
    suite, results = run_benchmarks(load_params=false)

    # Save the benchmark parameters:
    # https://github.com/JuliaCI/BenchmarkTools.jl/blob/master/doc/manual.md#caching-parameters
    BenchmarkTools.save(paramsfile, params(suite))

    # I also want to save the results.
    BenchmarkTools.save(resultsfile, results)
end

function compare_methods()
    suite, results = run_benchmarks()

    # Let's do some comparisons. What do I want to compare? The time and memory
    # allocations, I guess. First thing to check is that the composed
    # transformation is faster than the sequential.
    println("Composed vs sequential comparison: SteadyRotXTransformation, ConstantLinearMap, ConstantVelocityTransformation")
    r = results["composed vs sequential"]
    m_seq = median(r["sequential"])
    m_com = median(r["composed"])
    j = judge(m_com, m_seq)
    display(j)

    println("Sequential w/o splatting vs sequential comparison: SteadyRotXTransformation, ConstantLinearMap, ConstantVelocityTransformation")
    m_seq_no_splat = median(r["sequential_no_splatting"])
    j = judge(m_seq_no_splat, m_seq)
    display(j)

    println("Mutating vs allocating comparison, SteadyRotXTransformation:")
    r = results["mutating vs allocating"]["SteadyRotXTransformation"]
    m_mut = median(r["mutating"])
    m_all = median(r["allocating"])
    j = judge(m_mut, m_all)
    display(j)

    println("Mutating vs allocating comparison, ConstantLinearMap:")
    r = results["mutating vs allocating"]["ConstantLinearMap"]
    m_mut = median(r["mutating"])
    m_all = median(r["allocating"])
    j = judge(m_mut, m_all)
    display(j)

    println("Mutating vs allocating comparison, ConstantVelocityTransformation:")
    r = results["mutating vs allocating"]["ConstantVelocityTransformation"]
    m_mut = median(r["mutating"])
    m_all = median(r["allocating"])
    j = judge(m_mut, m_all)
    display(j)

    println("Mutating vs allocating comparison, composed transformation:")
    r = results["mutating vs allocating"]["composed"]
    m_mut = median(r["mutating"])
    m_all = median(r["allocating"])
    j = judge(m_mut, m_all)
    display(j)
end

function check_regressions()
    suite, results = run_benchmarks()

    # Now, let's compare the current results to the saved ones.
    oldresults = BenchmarkTools.load(resultsfile)[1]
    regression_results = Bool[]
    for (keys, trial) in leaves(results)
        oldtrial = oldresults[keys]
        mnew = median(trial)
        mold = median(oldtrial)
        j = judge(mnew, mold)
        println(keys)
        display(j)
        push!(regression_results, isregression(j))
    end

    return regression_results
end

if ! isinteractive()
    regs = check_regressions()
    if any(regs)
        exit(1)
    end
end
