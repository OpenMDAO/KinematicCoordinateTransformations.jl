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

function (trans::ConstantAffineMap)(t, x, v, a, j)
    x_new = trans.x_Mx*x + trans.x_b
    v_new = trans.v_Mx*x + trans.v_Mv*v + trans.v_b
    a_new = trans.a_Mx*x + trans.a_Mv*v + trans.a_Ma*a + trans.a_b
    j_new = trans.j_Mx*x + trans.j_Mv*v + trans.j_Ma*a + trans.j_Mj*j + trans.j_b

    return x_new, v_new, a_new, j_new
end
