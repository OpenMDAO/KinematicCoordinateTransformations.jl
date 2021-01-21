# This is completely stolen from CoordinateTransformations.jl. Every vector will
# be transformed the same way, I guess, so I only need one matrix.
@concrete struct ConstantLinearMap <: KinematicTransformation
    linear
end

function (trans::ConstantLinearMap)(t, x, v, a, j, linear_only::Bool=false)
    x_new = similar(x)
    v_new = similar(v)
    a_new = similar(a)
    j_new = similar(j)

    transform!(x_new, v_new, a_new, j_new, trans, t, x, v, a, j, linear_only)

    return x_new, v_new, a_new, j_new
end

function (trans::ConstantLinearMap)(t, x, v, a, linear_only::Bool=false)
    x_new = similar(x)
    v_new = similar(v)
    a_new = similar(a)

    transform!(x_new, v_new, a_new, trans, t, x, v, a, linear_only)

    return x_new, v_new, a_new
end

function (trans::ConstantLinearMap)(t, x, v, linear_only::Bool=false)
    x_new = similar(x)
    v_new = similar(v)

    transform!(x_new, v_new, trans, t, x, v, linear_only)

    return x_new, v_new
end

function (trans::ConstantLinearMap)(t, x, linear_only::Bool=false)
    x_new = similar(x)

    transform!(x_new, trans, t, x, linear_only)

    return x_new
end

function transform!(x_new, v_new, a_new, j_new, trans::ConstantLinearMap, t, x, v, a, j, linear_only::Bool=false)
    # x_new = trans.linear*x
    # v_new = trans.linear*v
    # a_new = trans.linear*a
    # j_new = trans.linear*j

    mul!(x_new, trans.linear, x)
    mul!(v_new, trans.linear, v)
    mul!(a_new, trans.linear, a)
    mul!(j_new, trans.linear, j)

    return nothing
end

function transform!(x_new, v_new, a_new, trans::ConstantLinearMap, t, x, v, a, linear_only::Bool=false)
    # x_new = trans.linear*x
    # v_new = trans.linear*v
    # a_new = trans.linear*a
    # j_new = trans.linear*j

    mul!(x_new, trans.linear, x)
    mul!(v_new, trans.linear, v)
    mul!(a_new, trans.linear, a)

    return nothing
end

function transform!(x_new, v_new, trans::ConstantLinearMap, t, x, v, linear_only::Bool=false)
    # x_new = trans.linear*x
    # v_new = trans.linear*v
    # a_new = trans.linear*a
    # j_new = trans.linear*j

    mul!(x_new, trans.linear, x)
    mul!(v_new, trans.linear, v)

    return nothing
end

function transform!(x_new, trans::ConstantLinearMap, t, x, linear_only::Bool=false)
    # x_new = trans.linear*x
    # v_new = trans.linear*v
    # a_new = trans.linear*a
    # j_new = trans.linear*j

    mul!(x_new, trans.linear, x)

    return nothing
end

function ConstantAffineMap(t, trans::ConstantLinearMap{M}) where {M}
    T = eltype(M)

    zvector = StaticArrays.@SVector [zero(T), zero(T), zero(T)]

    zmatrix = StaticArrays.@SMatrix [
        zero(T) zero(T) zero(T);
        zero(T) zero(T) zero(T);
        zero(T) zero(T) zero(T)]

    # x_new = trans.linear*x
    # v_new = trans.linear*v
    # a_new = trans.linear*a
    # j_new = trans.linear*j
    
    x_Mx = trans.linear
    x_b = zvector

    v_Mx = zmatrix
    v_Mv = trans.linear
    v_b = zvector

    a_Mx = zmatrix
    a_Mv = zmatrix
    a_Ma = trans.linear
    a_b = zvector

    j_Mx = zmatrix
    j_Mv = zmatrix
    j_Ma = zmatrix
    j_Mj = trans.linear
    j_b = zvector

    return ConstantAffineMap(x_Mx, x_b, v_Mx, v_Mv, v_b, a_Mx, a_Mv, a_Ma, a_b, j_Mx, j_Mv, j_Ma, j_Mj, j_b)
end
