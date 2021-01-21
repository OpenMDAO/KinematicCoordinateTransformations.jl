@concrete struct ConstantVelocityTransformation <: KinematicTransformation
    # Time at which the position of the source coordinate system's origin in the target coordinate system is equal to x0.
    t0
    # Position of the source coordinate system's in the target coordinate system's frame of reference at time t0.
    x0
    # (Constant) velocity of the source coordinate system relative to the
    # target coordinate system.
    v
end

function (trans::ConstantVelocityTransformation)(t, x, linear_only::Bool=false)
    x_new = similar(x)

    transform!(x_new, trans, t, x, linear_only)

    return x_new
end

function (trans::ConstantVelocityTransformation)(t, x, v, linear_only::Bool=false)
    x_new = similar(x)
    v_new = similar(v)

    transform!(x_new, v_new, trans, t, x, v, linear_only)

    return x_new, v_new
end

function (trans::ConstantVelocityTransformation)(t, x, v, a, linear_only::Bool=false)
    x_new = similar(x)
    v_new = similar(v)
    a_new = similar(a)

    transform!(x_new, v_new, a_new, trans, t, x, v, a, linear_only)

    return x_new, v_new, a_new
end

function (trans::ConstantVelocityTransformation)(t, x, v, a, j, linear_only::Bool=false)
    x_new = similar(x)
    v_new = similar(v)
    a_new = similar(a)
    j_new = similar(j)

    transform!(x_new, v_new, a_new, j_new, trans, t, x, v, a, j, linear_only)

    return x_new, v_new, a_new, j_new
end

function transform!(x_new, v_new, a_new, j_new, trans::ConstantVelocityTransformation, t, x, v, a, j, linear_only::Bool=false)
    x_new .= x
    v_new .= v
    a_new .= a
    j_new .= j
    if ! linear_only
        x_new .+= trans.x0 .+ (t - trans.t0)*trans.v
        v_new .+= trans.v
    end
    return x_new, v_new, a_new, j_new
end

function transform!(x_new, v_new, a_new, trans::ConstantVelocityTransformation, t, x, v, a, linear_only::Bool=false)
    x_new .= x
    v_new .= v
    a_new .= a
    if ! linear_only
        x_new .+= trans.x0 .+ (t - trans.t0)*trans.v
        v_new .+= trans.v
    end
    return x_new, v_new, a_new
end

function transform!(x_new, v_new, trans::ConstantVelocityTransformation, t, x, v, linear_only::Bool=false)
    x_new .= x
    v_new .= v
    if ! linear_only
        x_new .+= trans.x0 .+ (t - trans.t0)*trans.v
        v_new .+= trans.v
    end
    return x_new, v_new
end

function transform!(x_new, trans::ConstantVelocityTransformation, t, x, linear_only::Bool=false)
    x_new .= x
    if ! linear_only
        x_new .+= trans.x0 .+ (t - trans.t0)*trans.v
    end
    return x_new
end

function ConstantAffineMap(t, trans::ConstantVelocityTransformation{T,B}) where {T,B}
    # OK, hmm... so this transformation will only affect the position and
    # velocity, of course. So...
    # x_new = x + trans.v*(t - t0)
    # v_new = v + trans.v

    dx = trans.x0 + trans.v*(t - trans.t0)
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

    return ConstantAffineMap(x_Mx, x_b, v_Mx, v_Mv, v_b, a_Mx, a_Mv, a_Ma, a_b, j_Mx, j_Mv, j_Ma, j_Mj, j_b)
end
