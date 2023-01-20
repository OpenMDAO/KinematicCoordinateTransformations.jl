"""
    SteadyRotXTransformation(t0, ω, θ)

Construct a transformation of a reference frame rotating about the x axis at a constant rate `ω`.

The rotation angle as a function of time will be `angle = ω*(t - t0) + θ`.

# Arguments
* `t0`: Time at which the angle between the target and source coordinate systems' y and z axes is θ.
* `ω`: Rotation rate of the target coordinate system, in units of `rad/<time>`.
* `θ`: Angle between the target and source coordinate systems' y and z axes at time `t0`.
"""
@concrete struct SteadyRotXTransformation <: KinematicTransformation
    # Time at which the angle between the target and source coordinate systems'
    # y axis (and z axis) is θ.
    t0
    ω
    θ
end

function ConstantAffineMap(t, trans::SteadyRotXTransformation)
    ω = trans.ω
    angle = trans.ω*(t - trans.t0) + trans.θ
    s, c = sincos(angle)

    ωs = ω*s
    ωωs = ω*ωs
    ωωωs = ω*ωωs
    
    ωc = ω*c
    ωωc = ω*ωc
    ωωωc = ω*ωωc

    T = typeof(angle)
    
    # Rotation matrix.
    R = @SMatrix [
        one(T)  zero(T)  zero(T);
        zero(T)  c  -s;
        zero(T)  s   c]

    # Omega cross matrix.
    Ωx = @SMatrix [
        zero(T)  zero(T)  zero(T);
        zero(T)  -ωs  -ωc;
        zero(T)   ωc  -ωs]

    # Omega cross Omega cross matrix.
    ΩxΩx = @SMatrix [
        zero(T)  zero(T)  zero(T);
        zero(T)  -ωωc  ωωs;
        zero(T)  -ωωs  -ωωc]
    
    # Omega cross Omega cross Omega cross matrix.
    ΩxΩxΩx = @SMatrix [
        zero(T)  zero(T)  zero(T);
        zero(T)   ωωωs  ωωωc;
        zero(T)  -ωωωc  ωωωs]

    zvector = @SVector [zero(T), zero(T), zero(T)]
    
    # x_new = R*x
    # v_new = R*v + Ωx*x
    # a_new = R*a + 2*Ωx*v + ΩxΩx*x
    # j_new = R*j + 3*Ωx*a + 3*ΩxΩx*v + ΩxΩxΩx*x

    x_Mx = R
    x_b = zvector

    v_Mx = Ωx
    v_Mv = R
    v_b = zvector

    a_Mx = ΩxΩx
    a_Mv = 2*Ωx
    a_Ma = R
    a_b = zvector

    j_Mx = ΩxΩxΩx
    j_Mv = 3*ΩxΩx
    j_Ma = 3*Ωx
    j_Mj = R
    j_b = zvector

    return ConstantAffineMap(x_Mx, x_b, v_Mx, v_Mv, v_b, a_Mx, a_Mv, a_Ma, a_b, j_Mx, j_Mv, j_Ma, j_Mj, j_b)
end

