module KinematicCoordinateTransformations

using ConcreteStructs: @concrete
using LinearAlgebra
using StaticArrays: @SVector, @SMatrix

abstract type KinematicTransformation end
export KinematicTransformation

include("fallback_transforms.jl")
export transform!

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
