# KinematicCoordinateTransformations.jl

[![Tests](https://github.com/dingraha/KinematicCoordinateTransformations/actions/workflows/test.yaml/badge.svg)](https://github.com/dingraha/KinematicCoordinateTransformations/actions/workflows/test.yaml)

KinematicCoordinateTransformations.jl is a Julia package for performing chains of coordinate system transformations involving not only position, but also kinematic quantities such as velocity, acceleration, and jerk.
The transformations currently supported:

  * `ConstantAffineMap`: transformation of the form `x_new = A*x + b` for input vector `x`, where `A` and `b` are independent of time.
  * `ConstantLinearMap`: transformation of the form `x_new = A*x` for input vector `x`, where `A` is independent of time.
  * `ConstantVelocityTransformation`: transformation of the form `x_new = x .+ x0 .+ (t - t0).*v0`, where `x0`, `t0`, and `v0` are parameters associated with the transformation, and `t` is time.
  * `ConstantVelocityTransformation`: transformation of the form `x_new = x .+ x0 .+ (t - t0).*v0`, where `x0`, `t0`, and `v0` are parameters associated with the transformation, and `t` is time.
  * `SteadyRot{X,Y,Z}Transformation`: steady rotations about the ``X``, ``Y`` or ``Z`` axes. "Steady" here means rotating at a constant rate.

## Acknowledgements
This package was heavily inspired by [CoordinateTransformations.jl](https://github.com/JuliaGeometry/CoordinateTransformations.jl).

## Software Quality Assurance
* This repository contains extensive tests run by GitHub Actions.
* This repository only allows signed commits to be merged into the `main` branch.
