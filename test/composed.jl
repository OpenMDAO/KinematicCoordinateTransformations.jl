Test.@testset "Composed" begin

    Test.@testset "Constant velocity" begin
        trans1 = KinematicCoordinateTransformations.ConstantVelocityTransformation(1.0, StaticArrays.SVector(1.0, 2.0, 3.0), StaticArrays.SVector(2.0, 3.0, 4.0))
        trans2 = KinematicCoordinateTransformations.ConstantVelocityTransformation(2.0, StaticArrays.SVector(2.0, 3.0, 4.0), StaticArrays.SVector(3.0, 4.0, 5.0))

        t = 5.0
        t3 = KinematicCoordinateTransformations.compose(t, trans1, trans2)
        x = [3.0, 4.0, 5.0]
        v = [4.0, 5.0, 6.0]
        a = [2.0, 3.0, 4.0]
        j = [1.0, 2.0, 3.0]

        x12, v12, a12, j12 = trans1(t, trans2(t, x, v, a, j)...)
        x3, v3, a3, j3 = t3(t, x, v, a, j)

        Test.@test x3 ≈ x12
        Test.@test v3 ≈ v12
        Test.@test a3 ≈ a12
        Test.@test j3 ≈ j12

        t = 5.0
        t3 = KinematicCoordinateTransformations.compose(t, trans2, trans1)

        x21, v21, a21, j21 = trans2(t, trans1(t, x, v, a, j)...)
        x3, v3, a3, j3 = t3(t, x, v, a, j)

        Test.@test x3 ≈ x21
        Test.@test v3 ≈ v21
        Test.@test a3 ≈ a21
        Test.@test j3 ≈ j21
    end

    Test.@testset "Constant linear map" begin
        M1 = [1.0 4.0 7.0;
              2.0 5.0 8.0;
              3.0 6.0 9.0]
        trans1 = KinematicCoordinateTransformations.ConstantLinearMap(M1)
        M2 = [8.0 1.0 3.0;
              3.0 6.0 9.0;
              4.0 7.0 10.0]
        trans2 = KinematicCoordinateTransformations.ConstantLinearMap(M2)

        t = 3.0
        trans3 = KinematicCoordinateTransformations.compose(t, trans1, trans2)

        x = [2.0, 3.0, 4.0]
        v = [3.0, 4.0, 5.0]
        a = [4.0, 5.0, 6.0]
        j = [5.0, 6.0, 7.0]
        x12, v12, a12, j12 = trans1(t, trans2(t, x, v, a, j)...)

        x3, v3, a3, j3 = trans3(t, x, v, a, j)
        Test.@test x3 ≈ x12
        Test.@test v3 ≈ v12
        Test.@test a3 ≈ a12
        Test.@test j3 ≈ j12

        t = 3.0
        trans3 = KinematicCoordinateTransformations.compose(t, trans2, trans1)
        
        x21, v21, a21, j21 = trans2(t, trans1(t, x, v, a, j)...)
        x3, v3, a3, j3 = trans3(t, x, v, a, j)

        Test.@test x3 ≈ x21
        Test.@test v3 ≈ v21
        Test.@test a3 ≈ a21
        Test.@test j3 ≈ j21
    end

    Test.@testset "Steady X rotation transformation" begin
        t0 = 2.0
        ω = 2*pi
        θ = 5.0*pi/180.0
        trans1 = KinematicCoordinateTransformations.SteadyRotXTransformation(t0, ω, θ)

        t0 = 3.0
        ω = 2.5*pi
        θ = 6.0*pi/180.0
        trans2 = KinematicCoordinateTransformations.SteadyRotXTransformation(t0, ω, θ)

        t = 0.125
        trans3 = KinematicCoordinateTransformations.compose(t, trans1, trans2)

        x = [3.0, 4.0, 5.0]
        v = [1.5, 2.0, 3.0]
        a = [2.0, 3.0, 4.0]
        j = [3.0, 4.0, -2.0]

        x12, v12, a12, j12 = trans1(t, trans2(t, x, v, a, j)...)
        x3, v3, a3, j3 = trans3(t, x, v, a, j)

        Test.@test x3 ≈ x12
        Test.@test v3 ≈ v12
        Test.@test a3 ≈ a12
        Test.@test j3 ≈ j12

        t = 0.125
        trans3 = KinematicCoordinateTransformations.compose(t, trans2, trans1)

        x21, v21, a21, j21 = trans2(t, trans1(t, x, v, a, j)...)
        x3, v3, a3, j3 = trans3(t, x, v, a, j)

        Test.@test x3 ≈ x21
        Test.@test v3 ≈ v21
        Test.@test a3 ≈ a21
        Test.@test j3 ≈ j21

    end

    Test.@testset "Constant velocity and constant linear map" begin
        trans1 = KinematicCoordinateTransformations.ConstantVelocityTransformation(1.0, StaticArrays.SVector(1.0, 2.0, 3.0), StaticArrays.SVector(2.0, 3.0, 4.0))
        M2 = [8.0 1.0 3.0;
              3.0 6.0 9.0;
              4.0 7.0 10.0]
        trans2 = KinematicCoordinateTransformations.ConstantLinearMap(M2)

        t = 5.0
        t3 = KinematicCoordinateTransformations.compose(t, trans1, trans2)

        x = [3.0, 4.0, 5.0]
        v = [4.0, 5.0, 6.0]
        a = [2.0, 3.0, 4.0]
        j = [1.0, 2.0, 3.0]

        x12, v12, a12, j12 = trans1(t, trans2(t, x, v, a, j)...)
        x3, v3, a3, j3 = t3(t, x, v, a, j)
        Test.@test x3 ≈ x12
        Test.@test v3 ≈ v12
        Test.@test a3 ≈ a12
        Test.@test j3 ≈ j12

        t = 5.0
        t3 = KinematicCoordinateTransformations.compose(t, trans2, trans1)

        x21, v21, a21, j21 = trans2(t, trans1(t, x, v, a, j)...)
        x3, v3, a3, j3 = t3(t, x, v, a, j)
        Test.@test x3 ≈ x21
        Test.@test v3 ≈ v21
        Test.@test a3 ≈ a21
        Test.@test j3 ≈ j21

    end

    Test.@testset "Constant velocity and steady X rotation" begin
        trans1 = KinematicCoordinateTransformations.ConstantVelocityTransformation(1.0, StaticArrays.SVector(1.0, 2.0, 3.0), StaticArrays.SVector(2.0, 3.0, 4.0))
        M2 = [8.0 1.0 3.0;
              3.0 6.0 9.0;
              4.0 7.0 10.0]

        t0 = 3.0
        ω = 2.5*pi
        θ = 6.0*pi/180.0
        trans2 = KinematicCoordinateTransformations.SteadyRotXTransformation(t0, ω, θ)

        t = 5.0
        t3 = KinematicCoordinateTransformations.compose(t, trans1, trans2)

        x = [3.0, 4.0, 5.0]
        v = [4.0, 5.0, 6.0]
        a = [2.0, 3.0, 4.0]
        j = [1.0, 2.0, 3.0]

        x12, v12, a12, j12 = trans1(t, trans2(t, x, v, a, j)...)
        x3, v3, a3, j3 = t3(t, x, v, a, j)
        Test.@test x3 ≈ x12
        Test.@test v3 ≈ v12
        Test.@test a3 ≈ a12
        Test.@test j3 ≈ j12

        t = 5.0
        t3 = KinematicCoordinateTransformations.compose(t, trans2, trans1)

        x21, v21, a21, j21 = trans2(t, trans1(t, x, v, a, j)...)
        x3, v3, a3, j3 = t3(t, x, v, a, j)
        Test.@test x3 ≈ x21
        Test.@test v3 ≈ v21
        Test.@test a3 ≈ a21
        Test.@test j3 ≈ j21

    end

    Test.@testset "Steady X rotation and constant linear map" begin
        t0 = 2.0
        ω = 2*pi
        θ = 5.0*pi/180.0
        trans1 = KinematicCoordinateTransformations.SteadyRotXTransformation(t0, ω, θ)

        M2 = [8.0 1.0 3.0;
              3.0 6.0 9.0;
              4.0 7.0 10.0]
        trans2 = KinematicCoordinateTransformations.ConstantLinearMap(M2)

        t = 5.0
        t3 = KinematicCoordinateTransformations.compose(t, trans1, trans2)

        x = [3.0, 4.0, 5.0]
        v = [4.0, 5.0, 6.0]
        a = [2.0, 3.0, 4.0]
        j = [1.0, 2.0, 3.0]

        x12, v12, a12, j12 = trans1(t, trans2(t, x, v, a, j)...)
        x3, v3, a3, j3 = t3(t, x, v, a, j)
        Test.@test x3 ≈ x12
        Test.@test v3 ≈ v12
        Test.@test a3 ≈ a12
        Test.@test j3 ≈ j12

        t = 5.0
        t3 = KinematicCoordinateTransformations.compose(t, trans2, trans1)

        x21, v21, a21, j21 = trans2(t, trans1(t, x, v, a, j)...)
        x3, v3, a3, j3 = t3(t, x, v, a, j)
        Test.@test x3 ≈ x21
        Test.@test v3 ≈ v21
        Test.@test a3 ≈ a21
        Test.@test j3 ≈ j21

    end

end
