"""
    SteadyRotYTransformation(t0, ω, θ)

Construct a transformation of a reference frame rotating about the y axis at a constant rate `ω`.

The rotation angle as a function of time will be `angle = ω*(t - t0) + θ`.

# Arguments
* `t0`: Time at which the angle between the target and source coordinate systems' x and z axes is θ.
* `ω`: Rotation rate of the target coordinate system, in units of `rad/<time>`.
* `θ`: Angle between the target and source coordinate systems' x and z axes at time `t0`.
"""
@concrete struct SteadyRotYTransformation <: KinematicTransformation
    # Time at which the angle between the target and source coordinate systems'
    # x axis (and z axis) is θ.
    t0
    ω
    θ
end

function ConstantAffineMap(t, trans::SteadyRotYTransformation{T1,T2,T3}) where {T1,T2,T3}
    # Is this necessary? Not sure.
    T = promote_type(T1, promote_type(T2, T3))

    trans1 = ConstantLinearMap(
        @SMatrix [zero(T) one(T) zero(T)
                  -one(T) zero(T) zero(T)
                  zero(T) zero(T) one(T)])
    trans2 = SteadyRotXTransformation(trans.t0, trans.ω, trans.θ)
    trans3 = ConstantLinearMap(
        @SMatrix [zero(T) -one(T) zero(T)
                   one(T) zero(T) zero(T)
                  zero(T) zero(T) one(T)])

    trans12 = compose(t, trans2, trans1)
    trans123 = compose(t, trans3, trans12)

    return trans123
end
