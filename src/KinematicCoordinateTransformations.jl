module KinematicCoordinateTransformations

using ConcreteStructs: @concrete
using LinearAlgebra
import StaticArrays

abstract type KinematicTransformation end
export KinematicTransformation

include("constant_affine.jl")
export ConstantAffineMap

include("constant_velocity.jl")
export ConstantVelocityTransformation

include("steady_rot_x.jl")
export SteadyRotXTransformation

include("constant_linear_map.jl")
export ConstantLinearMap

include("composed.jl")
export compose

export transform!

end # module
