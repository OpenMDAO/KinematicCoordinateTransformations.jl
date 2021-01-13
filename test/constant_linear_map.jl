Test.@testset "Constant linear map" begin

    Test.@testset "Trivial" begin
        M = [0.0 0.0 0.0;
             0.0 0.0 0.0;
             0.0 0.0 0.0]
        trans = KinematicCoordinateTransformations.ConstantLinearMap(M)

        t = 8.0
        x = [2.0, 3.0, 4.0]
        v = [3.0, 4.0, 5.0]
        a = [4.0, 5.0, 6.0]
        j = [5.0, 6.0, 7.0]

        Test.@inferred trans(t, x, v, a, j)
        x_new, v_new, a_new, j_new = trans(t, x, v, a, j)

        Test.@test x_new ≈ [0.0, 0.0, 0.0]
        Test.@test v_new ≈ [0.0, 0.0, 0.0]
        Test.@test a_new ≈ [0.0, 0.0, 0.0]
        Test.@test j_new ≈ [0.0, 0.0, 0.0]
    end

    Test.@testset "Identity" begin
        M = [1.0 0.0 0.0;
             0.0 1.0 0.0;
             0.0 0.0 1.0]
        trans = KinematicCoordinateTransformations.ConstantLinearMap(M)

        t = 8.0
        x = [2.0, 3.0, 4.0]
        v = [3.0, 4.0, 5.0]
        a = [4.0, 5.0, 6.0]
        j = [5.0, 6.0, 7.0]

        Test.@inferred trans(t, x, v, a, j)
        x_new, v_new, a_new, j_new = trans(t, x, v, a, j)

        Test.@test x_new ≈ x
        Test.@test v_new ≈ v
        Test.@test a_new ≈ a
        Test.@test j_new ≈ j
    end

    Test.@testset "Switch" begin
        M = [0.0 0.0 1.0;
             1.0 0.0 0.0;
             0.0 1.0 0.0]
        trans = KinematicCoordinateTransformations.ConstantLinearMap(M)

        t = 8.0
        x = [2.0, 3.0, 4.0]
        v = [3.0, 4.0, 5.0]
        a = [4.0, 5.0, 6.0]
        j = [5.0, 6.0, 7.0]

        Test.@inferred trans(t, x, v, a, j)
        x_new, v_new, a_new, j_new = trans(t, x, v, a, j)

        Test.@test x_new ≈ [x[3], x[1], x[2]]
        Test.@test v_new ≈ [v[3], v[1], v[2]]
        Test.@test a_new ≈ [a[3], a[1], a[2]]
        Test.@test j_new ≈ [j[3], j[1], j[2]]
    end

    Test.@testset "General" begin
        M = [1.0 4.0 7.0;
             2.0 5.0 8.0;
             3.0 6.0 9.0]
        trans = KinematicCoordinateTransformations.ConstantLinearMap(M)

        t = 8.0
        x = [2.0, 3.0, 4.0]
        v = [3.0, 4.0, 5.0]
        a = [4.0, 5.0, 6.0]
        j = [5.0, 6.0, 7.0]

        Test.@inferred trans(t, x, v, a, j)
        x_new, v_new, a_new, j_new = trans(t, x, v, a, j)

        Test.@test x_new ≈ M*x
        Test.@test v_new ≈ M*v
        Test.@test a_new ≈ M*a
        Test.@test j_new ≈ M*j
    end

end
