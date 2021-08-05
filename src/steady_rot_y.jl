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
