```@meta
CurrentModule = KCTDocs
```
# Software Quality Assurance

## Tests
KinematicCoordinateTransformations.jl uses the usual Julia testing framework to implement and run tests.
The tests can be run locally after installing KinematicCoordinateTransformations.jl, and are also run automatically on GitHub Actions.

To run the tests locally, from the Julia REPL, type `]` to enter the Pkg prompt, then

```julia-repl
(jl_jncZ1E) pkg> test KinematicCoordinateTransformations
     Testing KinematicCoordinateTransformations
     Testing Running tests...
Test Summary:                      | Pass  Total  Time
KinematicCoordinateTransformations |  388    388  3.8s
     Testing KinematicCoordinateTransformations tests passed 

(jl_jncZ1E) pkg> 
```

(The output associated with installing all the dependencies the tests need isn't shown above.)

Most of the tests compare KinematicCoordinateTransformations.jl's functions against hand-calculated coordinate transformations, and a few trivial cases.
Also, the `compose` feature (where two or more transformations are combined into one) is compared to performing the equivalent transformation step-by-step.
Additionally, KinematicCoordinateTransformations.jl's tests use the automatic differentiation library [ForwardDiff.jl](https://github.com/JuliaDiff/ForwardDiff.jl) to check its implementation of velocity, acceleration, and jerk by comparing to the results of differentiating (with respect to time) a position, velocity, or acceleration function (see `tests/forwarddiff.jl`).


## Signed Commits
The KinematicCoordinateTransformations.jl GitHub repository requires all commits to the `main` branch to be signed.
See the [GitHub docs on signing commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification) for more information.

## Reporting Bugs
Users can use the [GitHub Issues](https://docs.github.com/en/issues/tracking-your-work-with-issues/about-issues) feature to report bugs and submit feature requests.
