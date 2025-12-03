
ENV["GKSwstype"] = "100"

const FIG_BASE = joinpath(@__DIR__, "../figures")
const FIG_ODE = joinpath(FIG_BASE, "ode_solver")
const FIG_MAP = joinpath(FIG_BASE, "map_solver")
const FIG_LAT = joinpath(FIG_BASE, "lattice")
const FIG_RANDOM = joinpath(FIG_BASE, "random")

const PATHS = Dict(
    # ODEs
    :vanderpol => joinpath(FIG_ODE, "vanderpol"),
    :hodgkin_huxley => joinpath(FIG_ODE, "hodgkin_huxley"),
    :lorenz => joinpath(FIG_ODE, "lorenz"),
    :rossler => joinpath(FIG_ODE, "rossler"),
    # maps
    :henon => joinpath(FIG_MAP, "henon_map"),
)
mkpath.(values(PATHS))

using DynamicalModels, Test, Plots
using FFTW, ForwardDiff
using LinearAlgebra, Statistics, Random

const dirs = ["model", "solver"]

@testset "tests" begin
    test_args = copy(ARGS)
    println("Passed arguments ARGS = $(test_args) to tests.")
        @time for dir in dirs
            dirpath = joinpath(@__DIR__, dir)
            println("\nTest $(dirpath)")
            # Find all files named test_*.jl in the directory and include them.
            files = sort(filter(f -> startswith(f, "test_") && endswith(f, ".jl"), readdir(dirpath)))
            if isempty(files)
                println("  No test files found in $(dirpath).")
            else
                for f in files
                    filepath = joinpath(dirpath, f)
                    @time begin
                        println("  Including $(filepath)")
                        include(filepath)
                    end
                end
            end
        end
    end
end