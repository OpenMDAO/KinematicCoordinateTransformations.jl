Test.@testset "Composed" begin

    Test.@testset "Constant velocity" begin
        t1 = KinematicCoordinateTransformations.ConstantVelocityTransformation(1.0, StaticArrays.SVector(1.0, 2.0, 3.0), StaticArrays.SVector(2.0, 3.0, 4.0))
        t2 = KinematicCoordinateTransformations.ConstantVelocityTransformation(2.0, StaticArrays.SVector(2.0, 3.0, 4.0), StaticArrays.SVector(3.0, 4.0, 5.0))
        t = 5.0
        t3 = KinematicCoordinateTransformations.compose(t, t1, t2)
        x = [3.0, 4.0, 5.0]
        v = [4.0, 5.0, 6.0]
        a = [2.0, 3.0, 4.0]
        j = [1.0, 2.0, 3.0]

        x_new12, v_new12, a_new12, j_new12 = t1(t, t2(t, x, v, a, j)...)
        x_new3, v_new3, a_new3, j_new3 = t3(t, x, v, a, j)
        Test.@test x_new3 ≈ x_new12
        Test.@test v_new3 ≈ v_new12
        Test.@test a_new3 ≈ a_new12
        Test.@test j_new3 ≈ j_new12

    end

end
