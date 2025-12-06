ENV["GKSwstype"] = "100"

using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using DynamicalModels
using Plots, LinearAlgebra, Random, Statistics, FFTW

const FIG_DIR = joinpath(pkgdir(DynamicalModels), "docs", "src", "assets", "figures")
const FIG_ODE = joinpath(FIG_DIR, "solver", "ode_solver")
mkpath(FIG_ODE)
const FIG_MODEL = joinpath(FIG_DIR, "model")
mkpath(FIG_MODEL)

const dirs = ["solver", "model"]

test_args = copy(ARGS)
println("Passed arguments ARGS = $(test_args) to tests.")
@time for dir in dirs
    dirpath = joinpath(@__DIR__, dir)
    println("\nTest $(dirpath)")
    files = sort(filter(f -> startswith(f, "fig_") && endswith(f, ".jl"), readdir(dirpath)))
    if isempty(files)
        println("  No figure files found in $(dirpath).")
    else
        for f in files
            filepath = joinpath(dirpath, f)
            println("  Including $(filepath)")
            include(filepath)
        end
    end
end