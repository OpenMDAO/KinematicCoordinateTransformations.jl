struct ConstantVelocityTransformation{T,B} <: KinematicTransformation
    # Time at which the position of the source coordinate system's origin in the target coordinate system is equal to x0.
    t0::T
    # Position of the source coordinate system's in the target coordinate system's frame of reference at time t0.
    x0::B
    # (Constant) velocity of the source coordinate system relative to the
    # target coordinate system.
    v::B
end

function (trans::ConstantVelocityTransformation{T,B})(t, x, v, a, j) where {T,B}
    x_new = x + trans.x0 + (t - trans.t0)*trans.v
    v_new = v + trans.v
    a_new = a
    j_new = j
    return x_new, v_new, a_new, j_new
end

function ConstantAffineMap(t, trans::ConstantVelocityTransformation{T,B}) where {T,B}
    # OK, hmm... so this transformation will only affect the position and
    # velocity, of course. So...
    # x_new = x + trans.v*(t - t0)
    # v_new = v + trans.v

    dx = trans.x0 + trans.v*(t - t0)
    dv = trans.v
    
    zvector = StaticArrays.@SVector [zero(T), zero(T), zero(T)]

    # Can I use the Identity matrix for this? I'd have to adjust the type
    # declaration, I guess.
    imatrix = StaticArrays.@SMatrix [
        one(T) zero(T) zero(T);
        zero(T) one(T) zero(T);
        zero(T) zero(T) one(T)]

    # There's also a "scaling" matrix/vector/whatever that I could use to
    # represent the zero matrix. But again, this couldn't have the same type as
    # the "real" matricies/vectors. And I don't think it would make a huge
    # difference, since once I compose the transformation, the composed matrix
    # will be non-zero.
    zmatrix = StaticArrays.@SMatrix [
        zero(T) zero(T) zero(T);
        zero(T) zero(T) zero(T);
        zero(T) zero(T) zero(T)]
    
    x_Mx = imatrix
    x_b = dx

    v_Mx = zmatrix
    v_Mv = imatrix
    v_b = dv

    a_Mx = zmatrix
    a_Mv = zmatrix
    a_Ma = imatrix
    a_b = zvector

    j_Mx = zmatrix
    j_Mv = zmatrix
    j_Ma = zmatrix
    j_Mj = imatrix
    j_b = zvector

    return ConstantAffineMap(x_Mx, x_b, v_Mx, v_Mv, v_b, a_Mx, a_Mv, a_Ma, a_v, j_Mx, j_Mv, j_Ma, j_Mj, j_b)
end
