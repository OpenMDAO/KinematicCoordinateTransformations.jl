using ForwardDiff: ForwardDiff

Test.@testset "ForwardDiff checks" begin

    Test.@testset "velocity" begin

        function position(t)
            t_scalar = only(t)
            x = [3.0, 4.0, 5.0]
            v = [1.0, 2.0, 3.0]

            trans0 = ConstantVelocityTransformation(5.0, StaticArrays.SVector{3, Float64}(0.0, 0.0, 0.0), v)

            M1 = StaticArrays.@SMatrix [8.0 1.0 3.0;
                                        3.0 6.0 9.0;
                                        4.0 7.0 10.0]
            trans1 = ConstantLinearMap(M1)

            t0 = 2.0
            ω = 2*pi
            θ = 5.0*pi/180.0
            trans2 = SteadyRotXTransformation(t0, ω, θ)

            t0 = 1.0
            ω = 3*pi
            θ = 3.0*pi/180.0
            trans3 = SteadyRotYTransformation(t0, ω, θ)

            t0 = 1.5
            ω = 4*pi
            θ = 4.0*pi/180.0
            trans4 = SteadyRotZTransformation(t0, ω, θ)

            trans = compose(t_scalar, trans4,
                        compose(t_scalar, trans3,
                            compose(t_scalar, trans2,
                                compose(t_scalar, trans1, trans0))))

            x_out = trans(t_scalar, x, false)

            return x_out
        end

        function velocity(t)
            t_scalar = only(t)
            x = [3.0, 4.0, 5.0]
            v = [1.0, 2.0, 3.0]

            M1 = StaticArrays.@SMatrix [8.0 1.0 3.0;
                                        3.0 6.0 9.0;
                                        4.0 7.0 10.0]
            trans1 = ConstantLinearMap(M1)

            t0 = 2.0
            ω = 2*pi
            θ = 5.0*pi/180.0
            trans2 = SteadyRotXTransformation(t0, ω, θ)

            t0 = 1.0
            ω = 3*pi
            θ = 3.0*pi/180.0
            trans3 = SteadyRotYTransformation(t0, ω, θ)

            t0 = 1.5
            ω = 4*pi
            θ = 4.0*pi/180.0
            trans4 = SteadyRotZTransformation(t0, ω, θ)

            trans = compose(t_scalar, trans4,
                        compose(t_scalar, trans3,
                            compose(t_scalar, trans2, trans1)))
                                

            x_out, v_out = trans(t_scalar, x, v, false)

            return v_out
        end

        t = [5.0]
        Test.@test all(velocity(t) .≈ ForwardDiff.jacobian(position, t)[:, 1])
    end

    Test.@testset "acceleration" begin

        function velocity(t)
            t_scalar = only(t)
            x = [3.0, 4.0, 5.0]
            v = [1.0, 2.0, 3.0]

            trans0 = ConstantVelocityTransformation(5.0, StaticArrays.SVector{3, Float64}(0.0, 0.0, 0.0), v)

            M1 = StaticArrays.@SMatrix [8.0 1.0 3.0;
                                        3.0 6.0 9.0;
                                        4.0 7.0 10.0]
            trans1 = ConstantLinearMap(M1)

            t0 = 2.0
            ω = 2*pi
            θ = 5.0*pi/180.0
            trans2 = SteadyRotXTransformation(t0, ω, θ)

            t0 = 1.0
            ω = 3*pi
            θ = 3.0*pi/180.0
            trans3 = SteadyRotYTransformation(t0, ω, θ)

            t0 = 1.5
            ω = 4*pi
            θ = 4.0*pi/180.0
            trans4 = SteadyRotZTransformation(t0, ω, θ)

            trans = compose(t_scalar, trans4,
                        compose(t_scalar, trans3,
                            compose(t_scalar, trans2,
                                compose(t_scalar, trans1, trans0))))
                                

            x_out, v_out = trans(t_scalar, x, [0.0, 0.0, 0.0], false)

            return v_out
        end

        function acceleration(t)
            t_scalar = only(t)
            x = [3.0, 4.0, 5.0]
            v = [1.0, 2.0, 3.0]
            a = [0.0, 0.0, 0.0]

            M1 = StaticArrays.@SMatrix [8.0 1.0 3.0;
                                        3.0 6.0 9.0;
                                        4.0 7.0 10.0]
            trans1 = ConstantLinearMap(M1)

            t0 = 2.0
            ω = 2*pi
            θ = 5.0*pi/180.0
            trans2 = SteadyRotXTransformation(t0, ω, θ)

            t0 = 1.0
            ω = 3*pi
            θ = 3.0*pi/180.0
            trans3 = SteadyRotYTransformation(t0, ω, θ)

            t0 = 1.5
            ω = 4*pi
            θ = 4.0*pi/180.0
            trans4 = SteadyRotZTransformation(t0, ω, θ)

            trans = compose(t_scalar, trans4,
                        compose(t_scalar, trans3,
                            compose(t_scalar, trans2, trans1)))
                                
            x_out, v_out, a_out = trans(t_scalar, x, v, a, false)

            return a_out
        end

        t = [5.0]
        Test.@test all(acceleration(t) .≈ ForwardDiff.jacobian(velocity, t)[:, 1])
    end

    Test.@testset "jerk" begin

        function acceleration(t)
            t_scalar = only(t)
            x = [3.0, 4.0, 5.0]
            v = [1.0, 2.0, 3.0]
            a = [0.0, 0.0, 0.0]

            trans0 = ConstantVelocityTransformation(5.0, StaticArrays.SVector{3, Float64}(0.0, 0.0, 0.0), v)

            M1 = StaticArrays.@SMatrix [8.0 1.0 3.0;
                                        3.0 6.0 9.0;
                                        4.0 7.0 10.0]
            trans1 = ConstantLinearMap(M1)

            t0 = 2.0
            ω = 2*pi
            θ = 5.0*pi/180.0
            trans2 = SteadyRotXTransformation(t0, ω, θ)

            t0 = 1.0
            ω = 3*pi
            θ = 3.0*pi/180.0
            trans3 = SteadyRotYTransformation(t0, ω, θ)

            t0 = 1.5
            ω = 4*pi
            θ = 4.0*pi/180.0
            trans4 = SteadyRotZTransformation(t0, ω, θ)

            trans = compose(t_scalar, trans4,
                        compose(t_scalar, trans3,
                            compose(t_scalar, trans2,
                                compose(t_scalar, trans1, trans0))))
                                

            x_out, v_out, a_out = trans(t_scalar, x, [0.0, 0.0, 0.0], a, false)

            return a_out
        end

        function jerk(t)
            t_scalar = only(t)
            x = [3.0, 4.0, 5.0]
            v = [1.0, 2.0, 3.0]
            a = [0.0, 0.0, 0.0]
            j = [0.0, 0.0, 0.0]

            M1 = StaticArrays.@SMatrix [8.0 1.0 3.0;
                                        3.0 6.0 9.0;
                                        4.0 7.0 10.0]
            trans1 = ConstantLinearMap(M1)

            t0 = 2.0
            ω = 2*pi
            θ = 5.0*pi/180.0
            trans2 = SteadyRotXTransformation(t0, ω, θ)

            t0 = 1.0
            ω = 3*pi
            θ = 3.0*pi/180.0
            trans3 = SteadyRotYTransformation(t0, ω, θ)

            t0 = 1.5
            ω = 4*pi
            θ = 4.0*pi/180.0
            trans4 = SteadyRotZTransformation(t0, ω, θ)

            trans = compose(t_scalar, trans4,
                        compose(t_scalar, trans3,
                            compose(t_scalar, trans2, trans1)))
                                
            x_out, v_out, a_out, j_out = trans(t_scalar, x, v, a, j, false)

            return j_out
        end

        t = [5.0]
        Test.@test all(jerk(t) .≈ ForwardDiff.jacobian(acceleration, t)[:, 1])
    end
end
