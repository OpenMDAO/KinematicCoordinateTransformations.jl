function (trans::KinematicTransformation)(t, x, v, a, j, linear_only::Bool=false)
    return transform(trans, t, x, v, a, j, linear_only)
end

function (trans::KinematicTransformation)(t, x, v, a, linear_only::Bool=false)
    return transform(trans, t, x, v, a, linear_only)
end

function (trans::KinematicTransformation)(t, x, v, linear_only::Bool=false)
    return transform(trans, t, x, v, linear_only)
end

function (trans::KinematicTransformation)(t, x, linear_only::Bool=false)
    return transform(trans, t, x, linear_only)
end

"""
    transform(trans::KinematicTransformation, t, x, [v, [a, [j]]], linear_only::Bool=false)

Transform vector `x`, and optionally `v`, `a`, and `j` from the source coordinate system to the target coordinate system at time `t` according to the transformation `trans`, returning `x` and optionally `v`, `a`, and `j` in the target coordinate system.

`v`, `a`, and `j` are the first through third time derivatives of `x`.

If `linear_only` is `true`, the constant part (if any) of the transformation will not be applied.
For example, with a `ConstantAffineMap`, which represents a transformation of the form `x_target = A*x_source + b`, the `b` will not be used.
This is useful for properly transforming vectors that don't represent the position of a point and time derivatives of the same (e.g. force).
"""
transform

function transform(trans::KinematicTransformation, t, x, v, a, j, linear_only::Bool=false)
    affine = ConstantAffineMap(t, trans)
    return transform(affine, t, x, v, a, j, linear_only)
end

function transform(trans::KinematicTransformation, t, x, v, a, linear_only::Bool=false)
    affine = ConstantAffineMap(t, trans)
    return transform(affine, t, x, v, a, linear_only)
end

function transform(trans::KinematicTransformation, t, x, v, linear_only::Bool=false)
    affine = ConstantAffineMap(t, trans)
    return transform(affine, t, x, v, linear_only)
end

function transform(trans::KinematicTransformation, t, x, linear_only::Bool=false)
    affine = ConstantAffineMap(t, trans)
    return transform(affine, t, x, linear_only)
end

"""
    transform!(x_new, [v_new, [a_new, [j_new]]], trans::KinematicTransformation, t, x, [v, [a, [j]]], linear_only::Bool=false)

Transform vector `x`, and optionally `v`, `a`, and `j` from the source coordinate system to the target coordinate system at time `t` according to the transformation `trans`, returning the results in `x_new` and optionally `v_new`, `a_new`, and `j_new` in the target coordinate system.

`v`, `a`, and `j` are the first through third time derivatives of `x`.

If `linear_only` is `true`, the constant part (if any) of the transformation will not be applied.
For example, with a `ConstantAffineMap`, which represents a transformation of the form `x_target = A*x_source + b`, the `b` will not be used.
This is useful for properly transforming vectors that don't represent the position of a point and time derivatives of the same (e.g. force).
"""
transform!

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
