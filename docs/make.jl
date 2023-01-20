module KCTDocs

using Documenter, KinematicCoordinateTransformations

function main()
    makedocs(
             sitename="KinematicCoordinateTransformations.jl",
             modules = [KinematicCoordinateTransformations],
             format=Documenter.HTML(prettyurls=get(ENV, "CI", nothing) == "true"),
             pages = ["Reference"=>"index.md"])
    # if get(ENV, "CI", nothing) == "true"
    #     deploydocs(repo="github.com/dingraha/KinematicCoordinateTransformations.jl.git", devbranch="main")
    # end
end

if !isinteractive()
    main()
end

end # module
