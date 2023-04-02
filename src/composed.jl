"""
    compose(t, trans1::KinematicTransformation, trans2::KinematicTransformation)

Return a transformation resulting from applying `trans2` and then `trans1` at time `t`.

This will likely return a `ConstantAffineMap`, but may return a more specific transformation.
For example, combining two `ConstantLinearMap`s will result in a new `ConstantLinearMap`.
"""
compose

function compose(t, trans1::ConstantVelocityTransformation, trans2::ConstantVelocityTransformation)
    v = trans1.v + trans2.v
    # So, t0 is the time when the source frame is at x0 from the target frame.
    # So, the x will look like this:
    #
    # x2 = x + x02 + (t - t02)*v2
    # x1 = x2 + x01 + (t - t01)*v1
    #    = (x + x02 + (t - t02)*v2) + x01 + (t - t01)*v1
    #    = x + x02 + x01 + (t - t02)*v2 + (t - t01)*v1
    #    = x + x02 + x01 + t*v2 - t02*v2 + t*v1 - t01*v1
    #    = x + x02 + x01 + t*(v2 + v1) - t02*v2 - t01*v1
    #    = x + x02 + x01 + t*(v2 + v1) - (t02*v2 + t01*v1)
    #    = x + x02 + x01 + t*(v2 + v1) - (t02*v2 + t01*v1)*(v2 + v1)/(v2 + v1)
    #    = x + x02 + x01 + (t - (t02*v2 + t01*v1)/(v2 + v1))*(v2 + v1)
    # x0 = trans1.x0 + trans2.x0
    # t0 = (trans1.t0*trans1.v + trans2.t0*trans2.v)/(trans1.v + trans2.v)
    #
    # That's no good because I'm dividing vectors. How about this:
    #
    # x2 = x + x02 + (t - t02)*v2
    # x1 = x2 + x01 + (t - t01)*v1
    #    = (x + x02 + (t - t02)*v2) + x01 + (t - t01)*v1
    #    = x + x02 + x01 + (t - t02)*v2 + (t - t01)*v1
    #    = x + (x02 - t02*v2) + (x01 - t01*v1) + t*v2 + t*v1
    #    = x + (x02 - t02*v2) + (x01 - t01*v1) + (v2 + v1)*t
    # x0 = trans1.x0 - trans1.t0*trans1.v + trans2.x0 - trans2.t0*trans2.v
    # t0 = zero(trans1.t0)

    # Hmm... but I don't like having the new `t0` be zero. So let's set it to
    # the average of the two original ones.
    t0 = 0.5*(trans1.t0 + trans2.t0)
    # x1 = x + (x02 - t02*v2) + (x01 - t01*v1) + (v2 + v1)*t
    #    = x + (x02 - t02*v2) + (x01 - t01*v1) + (v2 + v1)*0.5*(t01 + t02) + (v2 + v1)*(t - 0.5*(t01 + t02))
    x0 = trans1.x0 - trans1.t0*trans1.v + trans2.x0 - trans2.t0*trans2.v + (trans1.v + trans2.v)*t0
    return ConstantVelocityTransformation(t0, x0, v)
end

function compose(t, trans1::ConstantLinearMap, trans2::ConstantLinearMap)
    return ConstantLinearMap(trans1.linear*trans2.linear)
end

function compose(t, trans1::ConstantAffineMap, trans2::ConstantAffineMap)
    # To make things simpler.
    x_Mx1 = trans1.x_Mx
    x_b1 = trans1.x_b
    v_Mx1 = trans1.v_Mx
    v_Mv1 = trans1.v_Mv
    v_b1 = trans1.v_b
    a_Mx1 = trans1.a_Mx
    a_Mv1 = trans1.a_Mv
    a_Ma1 = trans1.a_Ma
    a_b1 = trans1.a_b
    j_Mx1 = trans1.j_Mx
    j_Mv1 = trans1.j_Mv
    j_Ma1 = trans1.j_Ma
    j_Mj1 = trans1.j_Mj
    j_b1 = trans1.j_b

    x_Mx2 = trans2.x_Mx
    x_b2 = trans2.x_b
    v_Mx2 = trans2.v_Mx
    v_Mv2 = trans2.v_Mv
    v_b2 = trans2.v_b
    a_Mx2 = trans2.a_Mx
    a_Mv2 = trans2.a_Mv
    a_Ma2 = trans2.a_Ma
    a_b2 = trans2.a_b
    j_Mx2 = trans2.j_Mx
    j_Mv2 = trans2.j_Mv
    j_Ma2 = trans2.j_Ma
    j_Mj2 = trans2.j_Mj
    j_b2 = trans2.j_b

    # OK, let's call the original stuff `old`, the stuff after applying trans2
    # to `old` called `2`, and the stuff after trans1 to `2`, `1`.
    # x2 = x_Mx2*x_old + x_b2
    # x1 = x_Mx1*x2 + x_b1
    # x1 = x_Mx1*(x_Mx2*x_old + x_b2) + x_b1
    # x1 = x_Mx1*x_Mx2*x_old + x_Mx1*x_b2 + x_b1
    x_Mx = x_Mx1*x_Mx2
    x_b = x_Mx1*x_b2 + x_b1

    # Now, what about v?
    # v2 = v_Mx2*x_old + v_Mv2*v_old + v_b2
    # v1 = v_Mx1*x2    + v_Mv1*v2    + v_b1
    # v1 = v_Mx1*(x_Mx2*x_old + x_b2) + v_Mv1*(v_Mx2*x_old + v_Mv2*v_old + v_b2) + v_b1
    # v1 = (v_Mx1*x_Mx2*x_old + v_Mx1*x_b2) + (v_Mv1*v_Mx2*x_old + v_Mv1*v_Mv2*v_old + v_Mv1*v_b2) + v_b1
    # v1 = (v_Mx1*x_Mx2 + v_Mv1*v_Mx2)*x_old + (v_Mv1*v_Mv2)*v_old + (v_Mx1*x_b2 + v_Mv1*v_b2 + v_b1)
    v_Mx = v_Mx1*x_Mx2 + v_Mv1*v_Mx2
    v_Mv = v_Mv1*v_Mv2
    v_b = v_Mx1*x_b2 + v_Mv1*v_b2 + v_b1

    # Next, a.
    # a2 = a_Mx2*x_old + a_Mv2*v_old + a_Ma2*a_old + a_b2
    # a1 = a_Mx1*x2 + a_Mv1*v2 + a_Ma1*a2 + a_b1
    # a1 = a_Mx1*(x_Mx2*x_old + x_b2) + a_Mv1*(v_Mx2*x_old + v_Mv2*v_old + v_b2) + a_Ma1*(a_Mx2*x_old + a_Mv2*v_old + a_Ma2*a_old + a_b2) + a_b1
    # a1 = (a_Mx1*x_Mx2*x_old + a_Mx1*x_b2) + (a_Mv1*v_Mx2*x_old + a_Mv1*v_Mv2*v_old + a_Mv1*v_b2) + (a_Ma1*a_Mx2*x_old + a_Ma1*a_Mv2*v_old + a_Ma1*a_Ma2*a_old + a_Ma1*a_b2) + a_b1
    # a1 = (a_Mx1*x_Mx2 + a_Mv1*v_Mx2 + a_Ma1*a_Mx2)*x_old + (a_Mv1*v_Mv2 + a_Ma1*a_Mv2)*v_old + (a_Ma1*a_Ma2)*a_old + (a_Mx1*x_b2 + a_Mv1*v_b2 + a_Ma1*a_b2 + a_b1)
    a_Mx = a_Mx1*x_Mx2 + a_Mv1*v_Mx2 + a_Ma1*a_Mx2
    a_Mv = a_Mv1*v_Mv2 + a_Ma1*a_Mv2
    a_Ma = a_Ma1*a_Ma2
    a_b = a_Mx1*x_b2 + a_Mv1*v_b2 + a_Ma1*a_b2 + a_b1

    # Finally, j.
    # j2 = j_Mx2*x_old + j_Mv2*v_old + j_Ma2*a_old + j_Mj2*j_old + j_b2
    # j1 = j_Mx1*x2 + j_Mv1*v2 + j_Ma1*a2 + j_Mj1*j2 + j_b1
    # j1 = j_Mx1*(x_Mx2*x_old + x_b2) + j_Mv1*(v_Mx2*x_old + v_Mv2*v_old + v_b2) + j_Ma1*(a_Mx2*x_old + a_Mv2*v_old + a_Ma2*a_old + a_b2) + j_Mj1*(j_Mx2*x_old + j_Mv2*v_old + j_Ma2*a_old + j_Mj2*j_old + j_b2) + j_b1
    # j1 = (j_Mx1*x_Mx2*x_old + j_Mx1*x_b2) + (j_Mv1*v_Mx2*x_old + j_Mv1*v_Mv2*v_old + j_Mv1*v_b2) + (j_Ma1*a_Mx2*x_old + j_Ma1*a_Mv2*v_old + j_Ma1*a_Ma2*a_old + j_Ma1*a_b2) + (j_Mj1*j_Mx2*x_old + j_Mj1*j_Mv2*v_old + j_Mj1*j_Ma2*a_old + j_Mj1*j_Mj2*j_old + j_Mj1*j_b2) + j_b1
    # j1 = (j_Mx1*x_Mx2 + j_Mv1*v_Mx2 + j_Ma1*a_Mx2 + j_Mj1*j_Mx2)*x_old + (j_Mv1*v_Mv2 + j_Ma1*a_Mv2+ j_Mj1*j_Mv2)*v_old + (j_Ma1*a_Ma2 + j_Mj1*j_Ma2)*a_old + (j_Mj1*j_Mj2)*j_old + (j_Mx1*x_b2 + j_Mv1*v_b2 + j_Ma1*a_b2 + j_Mj1*j_b2 + j_b1)
    j_Mx = j_Mx1*x_Mx2 + j_Mv1*v_Mx2 + j_Ma1*a_Mx2 + j_Mj1*j_Mx2
    j_Mv = j_Mv1*v_Mv2 + j_Ma1*a_Mv2+ j_Mj1*j_Mv2
    j_Ma = j_Ma1*a_Ma2 + j_Mj1*j_Ma2
    j_Mj = j_Mj1*j_Mj2
    j_b = j_Mx1*x_b2 + j_Mv1*v_b2 + j_Ma1*a_b2 + j_Mj1*j_b2 + j_b1

    # All done!
    return ConstantAffineMap(x_Mx, x_b, v_Mx, v_Mv, v_b, a_Mx, a_Mv, a_Ma, a_b, j_Mx, j_Mv, j_Ma, j_Mj, j_b)
end

# Fallback compose.
function compose(t, trans1, trans2)
    cam1 = ConstantAffineMap(t, trans1)
    cam2 = ConstantAffineMap(t, trans2)
    return compose(t, cam1, cam2)
end

