Test.@testset "Steady Z rotation transformation" begin

    Test.@testset "Trivial" begin
        t0 = 0.0
        ω = 0.0
        θ = 0.0
        t = 8.0
        x = [3.0, 4.0, 5.0]
        v = [8.0, 2.0, 2.0]
        a = [2.0, 3.0, 4.0]
        j = [1.0, 2.0, 3.0]
        trans = SteadyRotZTransformation(t0, ω, θ)
        Test.@inferred trans(t, x, v, a, j)

        x_new, v_new, a_new, j_new = trans(t, x, v, a, j)
        Test.@test x_new ≈ x
        Test.@test v_new ≈ v
        Test.@test a_new ≈ a
        Test.@test j_new ≈ j

        x_new, v_new, a_new, j_new = trans(t, x, v, a, j, true)
        Test.@test x_new ≈ x
        Test.@test v_new ≈ v
        Test.@test a_new ≈ a
        Test.@test j_new ≈ j
    end

    Test.@testset "Zero angle offset, stationary source point" begin
        t0 = 0.0
        ω = 2*pi
        θ = 0.0
        t = 0.125 # This should lead to a 45° rotation.
        angle = ω*(t - t0)
        x = [3.0, 4.0, 5.0]
        v = [0.0, 0.0, 0.0]
        a = [0.0, 0.0, 0.0]
        j = [0.0, 0.0, 0.0]
        trans = SteadyRotZTransformation(t0, ω, θ)
        Test.@inferred trans(t, x, v, a, j)

        # These are the Cartesian unit vectors of the rotating (source) frame
        # expressed in the stationary (target) frame. Got this idea from
        # https://en.wikipedia.org/wiki/Rotating_reference_frame.
        ihat = [cos(angle), sin(angle), 0.0]
        jhat = [-sin(angle), cos(angle), 0.0]
        khat = [0.0, 0.0, 1.0]

        # Rotation vector.
        Ω = [0.0, 0.0, ω]

        # Using the Cartesian unit vectors of the rotating frame defined above,
        # we can get the position vector of the stationary frame this way.
        X = x[1]*ihat + x[2]*jhat + x[3]*khat

        x_new, v_new, a_new, j_new = trans(t, x, v, a, j)
        Test.@test x_new ≈ X
        Test.@test v_new ≈ Ω×X
        Test.@test a_new ≈ Ω×(Ω×X)
        Test.@test j_new ≈ Ω×(Ω×(Ω×X))

        x_new, v_new, a_new, j_new = trans(t, x, v, a, j, true)
        Test.@test x_new ≈ X
        Test.@test v_new ≈ Ω×X
        Test.@test a_new ≈ Ω×(Ω×X)
        Test.@test j_new ≈ Ω×(Ω×(Ω×X))
    end

    Test.@testset "Non-zero angle offset, stationary source point" begin
        t0 = 0.0
        ω = 2*pi
        θ = 5*pi/180.0
        t = 0.125
        angle = ω*(t - t0) + θ
        x = [3.0, 4.0, 5.0]
        v = [0.0, 0.0, 0.0]
        a = [0.0, 0.0, 0.0]
        j = [0.0, 0.0, 0.0]
        trans = SteadyRotZTransformation(t0, ω, θ)
        Test.@inferred trans(t, x, v, a, j)

        # These are the Cartesian unit vectors of the rotating (source) frame
        # expressed in the stationary (target) frame. Got this idea from
        # https://en.wikipedia.org/wiki/Rotating_reference_frame.
        ihat = [cos(angle), sin(angle), 0.0]
        jhat = [-sin(angle), cos(angle), 0.0]
        khat = [0.0, 0.0, 1.0]

        # Rotation vector.
        Ω = [0.0, 0.0, ω]

        # Using the Cartesian unit vectors of the rotating frame defined above,
        # we can get the position vector of the stationary frame this way.
        X = x[1]*ihat + x[2]*jhat + x[3]*khat

        x_new, v_new, a_new, j_new = trans(t, x, v, a, j)
        Test.@test x_new ≈ X
        Test.@test v_new ≈ Ω×X
        Test.@test a_new ≈ Ω×(Ω×X)
        Test.@test j_new ≈ Ω×(Ω×(Ω×X))

        x_new, v_new, a_new, j_new = trans(t, x, v, a, j, true)
        Test.@test x_new ≈ X
        Test.@test v_new ≈ Ω×X
        Test.@test a_new ≈ Ω×(Ω×X)
        Test.@test j_new ≈ Ω×(Ω×(Ω×X))
    end

    Test.@testset "Non-zero angle offset, moving source point" begin
        t0 = 1.0
        ω = 2*pi
        θ = 5.0*pi/180.0
        t = 0.125
        angle = ω*(t - t0) + θ
        x = [3.0, 4.0, 5.0]
        v = [1.0, 2.0, 3.0]
        a = [0.0, 0.0, 0.0]
        j = [0.0, 0.0, 0.0]
        trans = SteadyRotZTransformation(t0, ω, θ)
        Test.@inferred trans(t, x, v, a, j)

        # These are the Cartesian unit vectors of the rotating (source) frame
        # expressed in the stationary (target) frame. Got this idea from
        # https://en.wikipedia.org/wiki/Rotating_reference_frame.
        ihat = [cos(angle), sin(angle), 0.0]
        jhat = [-sin(angle), cos(angle), 0.0]
        khat = [0.0, 0.0, 1.0]

        # Rotation vector.
        Ω = [0.0, 0.0, ω]

        # Using the Cartesian unit vectors of the rotating frame defined above,
        # we can get the position vector of the stationary frame this way.
        X = x[1]*ihat + x[2]*jhat + x[3]*khat
        V = v[1]*ihat + v[2]*jhat + v[3]*khat

        x_new, v_new, a_new, j_new = trans(t, x, v, a, j)
        Test.@test x_new ≈ X
        Test.@test v_new ≈ Ω×X + V
        Test.@test a_new ≈ Ω×(Ω×X) + 2*Ω×V
        Test.@test j_new ≈ Ω×(Ω×(Ω×X)) + 3*(Ω×(Ω×V))

        x_new, v_new, a_new, j_new = trans(t, x, v, a, j, true)
        Test.@test x_new ≈ X
        Test.@test v_new ≈ Ω×X + V
        Test.@test a_new ≈ Ω×(Ω×X) + 2*Ω×V
        Test.@test j_new ≈ Ω×(Ω×(Ω×X)) + 3*(Ω×(Ω×V))
    end

    Test.@testset "General" begin
        t0 = 2.0
        ω = 2*pi
        θ = 5.0*pi/180.0
        t = 0.125
        angle = ω*(t - t0) + θ
        x = [3.0, 4.0, 5.0]
        v = [1.5, 2.0, 3.0]
        a = [2.0, 3.0, 4.0]
        j = [3.0, 4.0, -2.0]
        trans = SteadyRotZTransformation(t0, ω, θ)
        Test.@inferred trans(t, x, v, a, j)

        # These are the Cartesian unit vectors of the rotating (source) frame
        # expressed in the stationary (target) frame. Got this idea from
        # https://en.wikipedia.org/wiki/Rotating_reference_frame.
        ihat = [cos(angle), sin(angle), 0.0]
        jhat = [-sin(angle), cos(angle), 0.0]
        khat = [0.0, 0.0, 1.0]

        # Rotation vector.
        Ω = [0.0, 0.0, ω]

        # Using the Cartesian unit vectors of the rotating frame defined above,
        # we can get the position vector of the stationary frame this way.
        X = x[1]*ihat + x[2]*jhat + x[3]*khat
        V = v[1]*ihat + v[2]*jhat + v[3]*khat
        A = a[1]*ihat + a[2]*jhat + a[3]*khat
        J = j[1]*ihat + j[2]*jhat + j[3]*khat

        x_new, v_new, a_new, j_new = trans(t, x, v, a, j)
        Test.@test x_new ≈ X
        Test.@test v_new ≈ V + Ω×X
        Test.@test a_new ≈ A + Ω×(Ω×X) + 2*Ω×V
        Test.@test j_new ≈ J + Ω×(Ω×(Ω×X)) + 3*(Ω×(Ω×V)) + 3*(Ω×A)

        x_new, v_new, a_new, j_new = trans(t, x, v, a, j, true)
        Test.@test x_new ≈ X
        Test.@test v_new ≈ V + Ω×X
        Test.@test a_new ≈ A + Ω×(Ω×X) + 2*Ω×V
        Test.@test j_new ≈ J + Ω×(Ω×(Ω×X)) + 3*(Ω×(Ω×V)) + 3*(Ω×A)
    end

    Test.@testset "Comparison to stationary hand-calculations" begin
        t0 = 0.0
        ω = 2*pi
        θ = 0.0
        trans = SteadyRotZTransformation(t0, ω, θ)

        x = [2.0, 0.0, 0.0]
        v = [0.0, 0.0, 0.0]
        a = [0.0, 0.0, 0.0]
        j = [0.0, 0.0, 0.0]

        t = 0.0
        Test.@inferred trans(t, x, v, a, j)

        x_new, v_new, a_new, j_new = trans(t, x, v, a, j)

        # Angle between the source and target frames is zero, so x_new should be
        # the same as x.
        Test.@test x_new ≈ x

        # The point isn't moving in the source reference frame, so the only
        # velocity in the target frame will be due to the rotation, which will
        # be ω*r pointed in the tangential direction.
        r = sqrt(sum(x[1:end-1].^2))
        Test.@test v_new ≈ [0.0, ω*r, 0.0]

        # And the acceleration will just be ω^2*r, but pointed radially inward.
        Test.@test a_new ≈ [-ω^2*r, 0.0, 0.0]

        # And what will the jerk be? Well, the derivative of acceleration. The
        # acceleration can be expressed as `a = -ω^2*r*rhat`, where `rhat` is
        # the unit vector pointing in the radial direction. So the derivative
        # of that would be `j = -ω^2*r*drhat_dt`, which would be `j =
        # -ω^2*r*(ω*thetahat) = -ω^3*r*thetahat`, where `thetahat` is the unit
        # vector in the tangential direction (same direction as the rotation of
        # the frame), right?
        Test.@test j_new ≈ [0.0, -ω^3*r, 0.0]

        # Doing all this with `linear_only = true`, which shouldn't change
        # anything.
        linear_only = true
        x_new, v_new, a_new, j_new = trans(t, x, v, a, j, linear_only)

        # Angle between the source and target frames is zero, so x_new should be
        # the same as x.
        Test.@test x_new ≈ x

        # The point isn't moving in the source reference frame, so the only
        # velocity in the target frame will be due to the rotation, which will
        # be ω*r pointed in the tangential direction.
        r = sqrt(sum(x[1:end-1].^2))
        Test.@test v_new ≈ [0.0, ω*r, 0.0]

        # And the acceleration will just be ω^2*r, but pointed radially inward.
        Test.@test a_new ≈ [-ω^2*r, 0.0, 0.0]

        # And what will the jerk be? Well, the derivative of acceleration. The
        # acceleration can be expressed as `a = -ω^2*r*rhat`, where `rhat` is
        # the unit vector pointing in the radial direction. So the derivative
        # of that would be `j = -ω^2*r*drhat_dt`, which would be `j =
        # -ω^2*r*(ω*thetahat) = -ω^3*r*thetahat`, where `thetahat` is the unit
        # vector in the tangential direction (same direction as the rotation of
        # the frame), right?
        Test.@test j_new ≈ [0.0, -ω^3*r, 0.0]

    end

    Test.@testset "Comparison to constant-velocity hand-calculations" begin
        t0 = 0.0
        ω = 2*pi
        θ = 0.0
        trans = SteadyRotZTransformation(t0, ω, θ)

        x = [2.0, 0.0, 0.0]
        v = [3.0, 0.0, 0.0]
        a = [0.0, 0.0, 0.0]
        j = [0.0, 0.0, 0.0]

        t = 0.0
        Test.@inferred trans(t, x, v, a, j)

        x_new, v_new, a_new, j_new = trans(t, x, v, a, j)

        # Angle between the source and target frames is zero, so x_new should be
        # the same as x.
        Test.@test x_new ≈ x

        # The point is moving in the source reference frame, so the
        # velocity in the target frame will be what it is in the rotating frame,
        # then add the velocity due to the rotation, which will
        # be ω*r pointed in the tangential direction.
        r = sqrt(sum(x[1:end-1].^2))
        Test.@test v_new ≈ v .+ [0.0, ω*r, 0.0]

        # The acceleration will include ω^2*r centrifigal acceleration, and the Coriolis acceleration.
        Test.@test a_new ≈ [-ω^2*r, 2*ω*v[1], 0.0]

        # And what will the jerk be? Well, the derivative of acceleration. The
        # acceleration can be expressed as `a = -ω^2*r*rhat`, where `rhat` is
        # the unit vector pointing in the radial direction. So the derivative
        # of that would be `j = -ω^2*r*drhat_dt`, which would be `j =
        # -ω^2*r*(ω*thetahat) = -ω^3*r*thetahat`, where `thetahat` is the unit
        # vector in the tangential direction (same direction as the rotation of
        # the frame), right? And then have to do something similar for the
        # Coreolis acceleration.
        Test.@test j_new ≈ [-3*ω^2*v[1], -ω^3*r, 0.0]

        # Doing all this with `linear_only = true`, which shouldn't change
        # anything.
        linear_only = true
        x_new, v_new, a_new, j_new = trans(t, x, v, a, j, linear_only)

        # Angle between the source and target frames is zero, so x_new should be
        # the same as x.
        Test.@test x_new ≈ x

        # The point is moving in the source reference frame, so the
        # velocity in the target frame will be what it is in the rotating frame,
        # then add the velocity due to the rotation, which will
        # be ω*r pointed in the tangential direction.
        r = sqrt(sum(x[1:end-1].^2))
        Test.@test v_new ≈ v .+ [0.0, ω*r, 0.0]

        # The acceleration will include ω^2*r centrifigal acceleration, and the Coriolis acceleration.
        Test.@test a_new ≈ [-ω^2*r, 2*ω*v[1], 0.0]

        # And what will the jerk be? Well, the derivative of acceleration. The
        # acceleration can be expressed as `a = -ω^2*r*rhat`, where `rhat` is
        # the unit vector pointing in the radial direction. So the derivative
        # of that would be `j = -ω^2*r*drhat_dt`, which would be `j =
        # -ω^2*r*(ω*thetahat) = -ω^3*r*thetahat`, where `thetahat` is the unit
        # vector in the tangential direction (same direction as the rotation of
        # the frame), right? And then have to do something similar for the
        # Coreolis acceleration.
        Test.@test j_new ≈ [-3*ω^2*v[1], -ω^3*r, 0.0]
    end

    Test.@testset "Comparison to accelerating hand-calculations" begin
        t0 = 0.0
        ω = 2*pi
        θ = 0.0
        trans = SteadyRotZTransformation(t0, ω, θ)

        x = [2.0, 0.0, 0.0]
        v = [3.0, 0.0, 0.0]
        a = [4.0, 0.0, 0.0]
        j = [0.0, 0.0, 0.0]

        t = 0.0
        Test.@inferred trans(t, x, v, a, j)

        x_new, v_new, a_new, j_new = trans(t, x, v, a, j)

        # Angle between the source and target frames is zero, so x_new should be
        # the same as x.
        Test.@test x_new ≈ x

        # The point is moving in the source reference frame, so the
        # velocity in the target frame will be what it is in the rotating frame,
        # then add the velocity due to the rotation, which will
        # be ω*r pointed in the tangential direction.
        r = sqrt(sum(x[1:end-1].^2))
        Test.@test v_new ≈ v .+ [0.0, ω*r, 0.0]

        # The acceleration will include ω^2*r centrifigal acceleration, and the Coriolis acceleration.
        Test.@test a_new ≈ a .+ [-ω^2*r, 2*ω*v[1], 0.0]

        # And what will the jerk be? Well, the derivative of acceleration. The
        # acceleration can be expressed as `a = -ω^2*r*rhat`, where `rhat` is
        # the unit vector pointing in the radial direction. So the derivative
        # of that would be `j = -ω^2*r*drhat_dt`, which would be `j =
        # -ω^2*r*(ω*thetahat) = -ω^3*r*thetahat`, where `thetahat` is the unit
        # vector in the tangential direction (same direction as the rotation of
        # the frame), right? And then have to do something similar for the
        # Coreolis acceleration. And something for the acceleration in the
        # rotating frame. In the rotating frame, the acceleration is pointed
        # radially outward. But it's constant, right? Yeah, but when I take the
        # derivative of it I have to cross it with the rotation vector, which
        # means it will be pointing in the tangential direction. OK.
        Test.@test j_new ≈ [-3*ω^2*v[1], -ω^3*r + 3*ω*a[1], 0.0]

        # Do it all again with `linear_only = true`, which shouldn't change
        # anything.
        linear_only = true
        x_new, v_new, a_new, j_new = trans(t, x, v, a, j, linear_only)

        # Angle between the source and target frames is zero, so x_new should be
        # the same as x.
        Test.@test x_new ≈ x

        # The point is moving in the source reference frame, so the
        # velocity in the target frame will be what it is in the rotating frame,
        # then add the velocity due to the rotation, which will
        # be ω*r pointed in the tangential direction.
        r = sqrt(sum(x[1:end-1].^2))
        Test.@test v_new ≈ v .+ [0.0, ω*r, 0.0]

        # The acceleration will include ω^2*r centrifigal acceleration, and the Coriolis acceleration.
        Test.@test a_new ≈ a .+ [-ω^2*r, 2*ω*v[1], 0.0]

        # And what will the jerk be? Well, the derivative of acceleration. The
        # acceleration can be expressed as `a = -ω^2*r*rhat`, where `rhat` is
        # the unit vector pointing in the radial direction. So the derivative
        # of that would be `j = -ω^2*r*drhat_dt`, which would be `j =
        # -ω^2*r*(ω*thetahat) = -ω^3*r*thetahat`, where `thetahat` is the unit
        # vector in the tangential direction (same direction as the rotation of
        # the frame), right? And then have to do something similar for the
        # Coreolis acceleration. And something for the acceleration in the
        # rotating frame. In the rotating frame, the acceleration is pointed
        # radially outward. But it's constant, right? Yeah, but when I take the
        # derivative of it I have to cross it with the rotation vector, which
        # means it will be pointing in the tangential direction. OK.
        Test.@test j_new ≈ [-3*ω^2*v[1], -ω^3*r + 3*ω*a[1], 0.0]
    end

end
