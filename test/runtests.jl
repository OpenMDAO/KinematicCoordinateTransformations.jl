using KinematicCoordinateTransformations

using LinearAlgebra: ×

using Random: Random
using StaticArrays: StaticArrays
using Test: Test

Test.@testset "KinematicCoordinateTransformations" begin

    include("constant_velocity.jl")
    include("steady_rot_x.jl")
    include("constant_linear_map.jl")
    include("composed.jl")
    include("steady_rot_y.jl")
    include("steady_rot_z.jl")
    include("ad.jl")

end
