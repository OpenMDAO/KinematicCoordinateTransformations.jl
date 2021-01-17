Test.@testset "Profiling" begin

    function get_test_input(N)
        T = Float64
        X = rand(T, (3, N))
        V = rand(T, (3, N))
        A = rand(T, (3, N))
        J = rand(T, (3, N))

        return X, V, A, J
    end

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

    N = 100
    X, V, A, J = get_test_input(N)

    X_new = similar(X)
    V_new = similar(V)
    A_new = similar(A)
    J_new = similar(J)

    suite = BenchmarkGroup()

    s1 = suite["composed vs sequential"] = BenchmarkGroup()
    s1["sequential"] = @benchmarkable $trans3($t, $trans2($t, $trans1($t, $X, $V, $A, $J)...)...)
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

    tune!(suite, verbose=false)
    results = run(suite, verbose=false)

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
