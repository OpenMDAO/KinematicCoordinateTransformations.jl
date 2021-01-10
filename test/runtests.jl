import KinematicCoordinateTransformations
import LinearAlgebra: ×
import StaticArrays
import Test

Test.@testset "KinematicCoordinateTransformations" begin

    include("constant_velocity.jl")
    include("steady_rot_x.jl")
    include("constant_linear_map.jl")
    include("composed.jl")

end
