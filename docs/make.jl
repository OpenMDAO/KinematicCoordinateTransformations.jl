module KCTDocs

using Documenter, KinematicCoordinateTransformations

function main()
    IN_CI = get(ENV, "CI", nothing)=="true"

    makedocs(
             sitename="KinematicCoordinateTransformations.jl",
             modules = [KinematicCoordinateTransformations],
             format=Documenter.HTML(prettyurls=IN_CI),
             pages = ["Reference"=>"index.md", "Software Quality Assurance"=>"sqa.md"])

    if IN_CI
        deploydocs(repo="github.com/OpenMDAO/KinematicCoordinateTransformations.jl.git", devbranch="main")
    end
end

if !isinteractive()
    main()
end

end # module
