@concrete struct SteadyRotXTransformation <: KinematicTransformation
    # Time at which the angle between the target and source coordinate systems'
    # y axis (and z axis) is θ.
    t0
    ω
    θ
end

function (trans::SteadyRotXTransformation)(t, x, v, a, j)
    x_new = similar(x)
    v_new = similar(v)
    a_new = similar(a)
    j_new = similar(j)

    transform!(x_new, v_new, a_new, j_new, trans, t, x, v, a, j)

    return x_new, v_new, a_new, j_new
end

function transform!(x_new, v_new, a_new, j_new, trans::SteadyRotXTransformation, t, x, v, a, j)
    # x_new = R*x
    # v_new = v + Ωx*x
    # a_new = a + 2*Ωx*v + ΩxΩx*x
    # j_new = j + 3*Ωx*a + 3*ΩxΩx*v + ΩxΩxΩx*x

    affine = ConstantAffineMap(t, trans)

    transform!(x_new, v_new, a_new, j_new, affine, t, x, v, a, j)

    return nothing
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

