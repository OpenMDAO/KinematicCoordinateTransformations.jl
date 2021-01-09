module KinematicCoordinateTransformations

import StaticArrays

abstract type KinematicTransformation end

struct ConstantAffineMap{M, B} <: KinematicTransformation
    # x_new = x_Mx*x + x_b
    x_Mx::M
    x_b::B

    # v_new = v_Mx*x + v_Mv*v + v_b
    v_Mx::M
    v_Mv::M
    v_b::B

    # a_new = a_Mx*x + a_Mv*v + a_Ma*a + a_b
    a_Mx::M
    a_Mv::M
    a_Ma::M
    a_b::B

    # j_new = j_Mx*x + j_Mv*v + j_Ma*a + j_Mj*j + j_b
    j_Mx::M
    j_Mv::M
    j_Ma::M
    j_Mj::M
    j_b::B
end

struct ConstantVelocityTransformation{T,B} <: KinematicTransformation
    # Time at which the position of the source coordinate system's origin in the target coordinate system is equal to x0.
    t0::T
    # Position of the source coordinate system's in the target coordinate system's frame of reference at time t0.
    x0::B
    # (Constant) velocity of the source coordinate system relative to the
    # target coordinate system.
    v::B
end

struct SteadyRotXTransformation{T} <: KinematicTransformation
    # Time at which the angle between the target and source coordinate systems'
    # y axis (and z axis) is θ.
    t0::T
    ω::T
    θ::T
end

# This is completely stolen from CoordinateTransformations.jl. Every vector will
# be transformed the same way, I guess, so I only need one matrix.
struct ConstantLinearMap{M} <: KinematicTransformation
    linear::M
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

# function compose(t, trans1::ConstantVelocityTransformation, trans2::ConstantVelocityTransformation)
#     x0 = trans1.x0 + trans2.x0
#     v = trans1.v + trans2.v
#     t0 = (trans1.t0*trans1.v + trans2.t0*trans2.v)/(trans1.v + trans2.v)
#     return ConstantVelocityTranslation(t0, x0, v)
# end

function (trans::SteadyRotXTransformation{T})(t, x, v, a, j) where {T}
    # x_new = R*x
    # v_new = v + Ωx*x
    # a_new = a + 2*Ωx*v + ΩxΩx*x
    # j_new = j + 3*Ωx*a + 3*ΩxΩx*v + ΩxΩxΩx*x

    affine = ConstantAffineMap(t, trans)
    return affine(t, x, v, a, j)
end

function ConstantAffineMap(t, trans::SteadyRotXTransformation{T}) where {T}
    ω = trans.ω
    angle = trans.ω*(t - trans.t0) + trans.θ
    s, c = sincos(angle)

    ωs = ω*s
    ωωs = ω*ωs
    ωωωs = ω*ωωs
    
    ωc = ω*c
    ωωc = ω*ωc
    ωωωc = ω*ωωc
    
    # Rotation matrix.
    R = StaticArrays.@SMatrix [
        one(T)  zero(T)  zero(T);
        zero(T)  c  -s;
        zero(T)  s   c]

    # Omega cross matrix.
    Ωx = StaticArrays.@SMatrix [
        zero(T)  zero(T)  zero(T);
        zero(T)  -ωs  -ωc;
        zero(T)   ωc  -ωs]

    # Omega cross Omega cross matrix.
    ΩxΩx = StaticArrays.@SMatrix [
        zero(T)  zero(T)  zero(T);
        zero(T)  -ωωc  ωωs;
        zero(T)  -ωωs  -ωωc]
    
    # Omega cross Omega cross Omega cross matrix.
    ΩxΩxΩx = StaticArrays.@SMatrix [
        zero(T)  zero(T)  zero(T);
        zero(T)   ωωωs  ωωωc;
        zero(T)  -ωωωc  ωωωs]

    zvector = StaticArrays.@SVector [zero(T), zero(T), zero(T)]
    # Can I use the Identity matrix for this? I'd have to adjust the type
    # declaration, I guess.
    imatrix = StaticArrays.@SMatrix [
        one(T)  zero(T)  zero(T);
        zero(T)  one(T)  zero(T);
        zero(T)  zero(T)  one(T)]
    
    # x_new = R*x
    # v_new = v + Ωx*x
    # a_new = a + 2*Ωx*v + ΩxΩx*x
    # j_new = j + 3*Ωx*a + 3*ΩxΩx*v + ΩxΩxΩx*x

    x_Mx = R
    x_b = zvector

    v_Mx = Ωx
    v_Mv = imatrix
    v_b = zvector

    a_Mx = ΩxΩx
    a_Mv = 2*Ωx
    a_Ma = imatrix
    a_b = zvector

    j_Mx = ΩxΩxΩx
    j_Mv = 3*ΩxΩx
    j_Ma = 3*Ωx
    j_Mj = imatrix
    j_b = zvector

    return ConstantAffineMap(x_Mx, x_b, v_Mx, v_Mv, v_b, a_Mx, a_Mv, a_Ma, a_b, j_Mx, j_Mv, j_Ma, j_Mj, j_b)
end

function (trans::ConstantAffineMap)(t, x, v, a, j)
    x_new = trans.x_Mx*x + trans.x_b
    v_new = trans.v_Mx*x + trans.v_Mv*v + trans.v_b
    a_new = trans.a_Mx*x + trans.a_Mv*v + trans.a_Ma*a + trans.a_b
    j_new = trans.j_Mx*x + trans.j_Mv*v + trans.j_Ma*a + trans.j_Mj*j + trans.j_b

    return x_new, v_new, a_new, j_new
end

function (trans::ConstantLinearMap)(t, x, v, a, j)
    x_new = trans.linear*x
    v_new = trans.linear*v
    a_new = trans.linear*a
    j_new = trans.linear*j

    return x_new, v_new, a_new, j_new
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

    return ConstantAffineMap(x_Mx, x_b, v_Mx, v_Mv, v_b, a_Mx, a_Mv, a_Ma, a_v, j_Mx, j_Mv, j_Ma, j_Mj, j_b)
end

# function compose(trans1::ConstantAffineMap, trans2::ConstantAffineMap)
#     # To make things simpler.
#     x_Mx1 = trans1.x_Mx
#     x_b1 = trans1.x_b
#     v_Mx1 = trans1.v_Mx
#     v_Mv1 = trans1.v_Mv
#     v_b1 = trans1.v_b
#     a_Mx1 = trans1.a_Mx
#     a_Mv1 = trans1.a_Mv
#     a_Ma1 = trans1.a_Ma
#     a_b1 = trans1.a_b
#     j_Mx1 = trans1.j_Mx
#     j_Mv1 = trans1.j_Mv
#     j_Ma1 = trans1.j_Ma
#     j_Mj1 = trans1.j_Mj
#     j_b1 = trans1.j_b

#     x_Mx2 = trans2.x_Mx
#     x_b2 = trans2.x_b
#     v_Mx2 = trans2.v_Mx
#     v_Mv2 = trans2.v_Mv
#     v_b2 = trans2.v_b
#     a_Mx2 = trans2.a_Mx
#     a_Mv2 = trans2.a_Mv
#     a_Ma2 = trans2.a_Ma
#     a_b2 = trans2.a_b
#     j_Mx2 = trans2.j_Mx
#     j_Mv2 = trans2.j_Mv
#     j_Ma2 = trans2.j_Ma
#     j_Mj2 = trans2.j_Mj
#     j_b2 = trans2.j_b

#     # OK, let's call the original stuff `old`, the stuff after applying trans2
#     # to `old` called `2`, and the stuff after trans1 to `2`, `1`.
#     # x2 = x_Mx2*x_old + x_b2
#     # x1 = x_Mx1*x2 + x_b1
#     # x1 = x_Mx1*(x_Mx2*x_old + x_b2) + x_b1
#     # x1 = x_Mx1*x_Mx2*x_old + x_Mx1*x_b2 + x_b1
#     x_Mx = x_Mx1*x_Mx2
#     x_b = x_Mx1*x_b2 + x_b1

#     # Now, what about v?
#     # v2 = v_Mx2*x_old + v_Mv2*v_old + v_b2
#     # v1 = v_Mx1*x2    + v_Mv1*v2    + v_b1
#     # v1 = v_Mx1*(x_Mx2*x_old + x_b2) + v_Mv1*(v_Mx2*x_old + v_Mv2*v_old + v_b2) + v_b1
#     # v1 = (v_Mx1*x_Mx2*x_old + v_Mx1*x_b2) + (v_Mv1*v_Mx2*x_old + v_Mv1*v_Mv2*v_old + v_Mv1*v_b2) + v_b1
#     # v1 = (v_Mx1*x_Mx2 + v_Mv1*v_Mx2)*x_old + (v_Mv1*v_Mv2)*v_old + (v_Mx1*x_b2 + v_Mv1*v_b2 + v_b1)
#     v_Mx = v_Mx1*x_Mx2 + v_Mv1*v_Mx2
#     v_Mv = v_Mv1*v_Mv2
#     v_b = v_Mx1*x_b2 + v_Mv1*v_b2 + v_b1

#     # Next, a.
#     # a2 = a_Mx2*x_old + a_Mv2*v_old + a_Ma2*a_old + a_b2
#     # a1 = a_Mx1*x2 + a_Mv1*v2 + a_Ma1*a2 + a_b1
#     # a1 = a_Mx1*(x_Mx2*x_old + x_b2) + a_Mv1*(v_Mx2*x_old + v_Mv2*v_old + v_b2) + a_Ma1*(a_Mx2*x_old + a_Mv2*v_old + a_Ma2*a_old + a_b2) + a_b1
#     # a1 = (a_Mx1*x_Mx2*x_old + a_Mx1*x_b2) + (a_Mv1*v_Mx2*x_old + a_Mv1*v_Mv2*v_old + a_Mv1*v_b2) + (a_Ma1*a_Mx2*x_old + a_Ma1*a_Mv2*v_old + a_Ma1*a_Ma2*a_old + a_Ma1*a_b2) + a_b1
#     # a1 = (a_Mx1*x_Mx2 + a_Mv1*v_Mx2 + a_Ma1*a_Mx2)*x_old + (a_Mv1*v_Mv2 + a_Ma1*a_Mv2)*v_old + (a_Ma1*a_Ma2)*a_old + (a_Mx1*x_b2 + a_Mv1*v_b2 + a_Ma1*a_b2 + a_b1)
#     a_Mx = a_Mx1*x_Mx2 + a_Mv1*v_Mx2 + a_Ma1*a_Mx2
#     a_Mv = a_Mv1*v_Mv2 + a_Ma1*a_Mv2
#     a_Ma = a_Ma1*a_Ma2
#     a_b = a_Mx1*x_b2 + a_Mv1*v_b2 + a_Ma1*a_b2 + a_b1

#     # Finally, j.
#     # j2 = j_Mx2*x_old + j_Mv2*v_old + j_Ma2*a_old + j_Mj2*j_old + j_b2
#     # j1 = j_Mx1*x2 + j_Mv1*v2 + j_Ma1*a2 + j_Mj1*j2 + j_b1
#     # j1 = j_Mx1*(x_Mx2*x_old + x_b2) + j_Mv1*(v_Mx2*x_old + v_Mv2*v_old + v_b2) + j_Ma1*(a_Mx2*x_old + a_Mv2*v_old + a_Ma2*a_old + a_b2) + j_Mj1*(j_Mx2*x_old + j_Mv2*v_old + j_Ma2*a_old + j_Mj2*j_old + j_b2) + j_b1
#     # j1 = (j_Mx1*x_Mx2*x_old + j_Mx1*x_b2) + (j_Mv1*v_Mx2*x_old + j_Mv1*v_Mv2*v_old + j_Mv1*v_b2) + (j_Ma1*a_Mx2*x_old + j_Ma1*a_Mv2*v_old + j_Ma1*a_Ma2*a_old + j_Ma1*a_b2) + (j_Mj1*j_Mx2*x_old + j_Mj1*j_Mv2*v_old + j_Mj1*j_Ma2*a_old + j_Mj1*j_Mj2*j_old + j_Mj1*j_b2) + j_b1
#     # j1 = (j_Mx1*x_Mx2 + j_Mv1*v_Mx2 + j_Ma1*a_Mx2 + j_Mj1*j_Mx2)*x_old + (j_Mv1*v_Mv2 + j_Ma1*a_Mv2+ j_Mj1*j_Mv2)*v_old + (j_Ma1*a_Ma2 + j_Mj1*j_Ma2)*a_old + (j_Mj1*j_Mj2)*j_old + (j_Mx1*x_b2 + j_Mv1*v_b2 + j_Ma1*a_b2 + j_Mj1*j_b2 + j_b1)
#     j_Mx = j_Mx1*x_Mx2 + j_Mv1*v_Mx2 + j_Ma1*a_Mx2 + j_Mj1*j_Mx2
#     j_Mv = j_Mv1*v_Mv2 + j_Ma1*a_Mv2+ j_Mj1*j_Mv2
#     j_Ma = j_Ma1*a_Ma2 + j_Mj1*j_Ma2
#     j_Mj = j_Mj1*j_Mj2
#     j_b = j_Mx1*x_b2 + j_Mv1*v_b2 + j_Ma1*a_b2 + j_Mj1*j_b2 + j_b1

#     # All done!
#     return ConstantAffineMap(x_Mx, x_b, v_Mx, v_Mv, v_b, a_Mx, a_Mv, a_Ma, a_v, j_Mx, j_Mv, j_Ma, j_Mj, j_b)
# end


# """
# A `ComposedKinematicTransformation` simply executes two transformations successively, and
# is the fallback output type of `compose()`.
# """
# struct ComposedKinematicTransformation{T1<:KinematicTransformations, T2<:KinematicTransformation} <: KinematicTransformation
#     t1::T1
#     t2::T2
# end

# @inline function (trans::ComposedKinematicTransformation)(t, x, v, a, j)
#     trans.t1(t, trans.t2(t, x, v, a, j))
# end

end # module
