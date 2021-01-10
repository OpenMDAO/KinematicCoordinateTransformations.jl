module KinematicCoordinateTransformations

import StaticArrays

abstract type KinematicTransformation end

include("constant_affine.jl")
include("constant_velocity.jl")
include("steady_rot_x.jl")
include("constant_linear_map.jl")
include("composed.jl")

end # module
