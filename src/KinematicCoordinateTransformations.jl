module KinematicCoordinateTransformations

using ConcreteStructs: @concrete
using LinearAlgebra
using StaticArrays: @SVector, @SMatrix

"""
    KinematicTransformation

An abstract type representing a transformation of kinematic quantities.


    (trans::KinematicTransformation)(t, x, [v, [a, [j]]], linear_only::Bool=false)

Transform vector `x`, and optionally `v`, `a`, and `j` from the source coordinate system to the target coordinate system at time `t` according to the transformation `trans`, returning `x` and optionally `v`, `a`, and `j` in the target coordinate system.

`v`, `a`, and `j` are the first through third time derivatives of `x`.

If `linear_only` is `true`, the constant part (if any) of the transformation will not be applied.
For example, with a `ConstantAffineMap`, which represents a transformation of the form `x_target = A*x_source + b`, the `b` will not be used.
This is useful for properly transforming vectors that don't represent the position of a point and time derivatives of the same (e.g. force).
"""
abstract type KinematicTransformation end
export KinematicTransformation

include("fallback_transforms.jl")
export transform!, transform

include("constant_affine.jl")
export ConstantAffineMap

include("constant_velocity.jl")
export ConstantVelocityTransformation

include("steady_rot_x.jl")
export SteadyRotXTransformation

include("steady_rot_y.jl")
export SteadyRotYTransformation

include("steady_rot_z.jl")
export SteadyRotZTransformation

include("constant_linear_map.jl")
export ConstantLinearMap

include("composed.jl")
export compose

end # module
