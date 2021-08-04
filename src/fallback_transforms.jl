function (trans::KinematicTransformation)(t, x, v, a, j, linear_only::Bool=false)
    x_new = similar(x)
    v_new = similar(v)
    a_new = similar(a)
    j_new = similar(j)

    transform!(x_new, v_new, a_new, j_new, trans, t, x, v, a, j, linear_only)

    return x_new, v_new, a_new, j_new
end

function (trans::KinematicTransformation)(t, x, v, a, linear_only::Bool=false)
    x_new = similar(x)
    v_new = similar(v)
    a_new = similar(a)

    transform!(x_new, v_new, a_new, trans, t, x, v, a, linear_only)

    return x_new, v_new, a_new
end

function (trans::KinematicTransformation)(t, x, v, linear_only::Bool=false)
    x_new = similar(x)
    v_new = similar(v)

    transform!(x_new, v_new, trans, t, x, v, linear_only)

    return x_new, v_new
end

function (trans::KinematicTransformation)(t, x, linear_only::Bool=false)
    x_new = similar(x)

    transform!(x_new, trans, t, x, linear_only)

    return x_new
end

function transform!(x_new, v_new, a_new, j_new, trans::KinematicTransformation, t, x, v, a, j, linear_only::Bool=false)
    # x_new = R*x
    # v_new = v + Ωx*x
    # a_new = a + 2*Ωx*v + ΩxΩx*x
    # j_new = j + 3*Ωx*a + 3*ΩxΩx*v + ΩxΩxΩx*x

    affine = ConstantAffineMap(t, trans)

    transform!(x_new, v_new, a_new, j_new, affine, t, x, v, a, j, linear_only)

    return nothing
end

function transform!(x_new, v_new, a_new, trans::KinematicTransformation, t, x, v, a, linear_only::Bool=false)
    # x_new = R*x
    # v_new = v + Ωx*x
    # a_new = a + 2*Ωx*v + ΩxΩx*x
    # j_new = j + 3*Ωx*a + 3*ΩxΩx*v + ΩxΩxΩx*x

    affine = ConstantAffineMap(t, trans)

    transform!(x_new, v_new, a_new, affine, t, x, v, a, linear_only)

    return nothing
end

function transform!(x_new, v_new, trans::KinematicTransformation, t, x, v, linear_only::Bool=false)
    # x_new = R*x
    # v_new = v + Ωx*x
    # a_new = a + 2*Ωx*v + ΩxΩx*x
    # j_new = j + 3*Ωx*a + 3*ΩxΩx*v + ΩxΩxΩx*x

    affine = ConstantAffineMap(t, trans)

    transform!(x_new, v_new, affine, t, x, v, linear_only)

    return nothing
end

function transform!(x_new, trans::KinematicTransformation, t, x, linear_only::Bool=false)
    # x_new = R*x
    # v_new = v + Ωx*x
    # a_new = a + 2*Ωx*v + ΩxΩx*x
    # j_new = j + 3*Ωx*a + 3*ΩxΩx*v + ΩxΩxΩx*x

    affine = ConstantAffineMap(t, trans)

    transform!(x_new, affine, t, x, linear_only)

    return nothing
end
