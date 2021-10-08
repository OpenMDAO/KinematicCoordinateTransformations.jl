@concrete struct SteadyRotZTransformation <: KinematicTransformation
    # Time at which the angle between the target and source coordinate systems'
    # x axis (and y axis) is θ.
    t0
    ω
    θ
end

function ConstantAffineMap(t::Number, trans::SteadyRotZTransformation{T1,T2,T3}) where {T1,T2,T3}
    # Is this necessary? Not sure.
    T = promote_type(T1, promote_type(T2, T3))

    trans1 = ConstantLinearMap(
        @SMatrix [zero(T) zero(T) one(T)
                  zero(T) one(T) zero(T)
                 -one(T) zero(T) zero(T)])
    trans2 = SteadyRotXTransformation(trans.t0, trans.ω, trans.θ)
    trans3 = ConstantLinearMap(
        @SMatrix [zero(T) zero(T) -one(T)
                  zero(T) one(T) zero(T)
                  one(T) zero(T) zero(T)])

    trans12 = compose(t, trans2, trans1)
    trans123 = compose(t, trans3, trans12)

    return trans123
end

function ConstantAffineMap(trans::SteadyRotZTransformation)
    t = trans.t0
    return ConstantAffineMap(t, trans)
end
