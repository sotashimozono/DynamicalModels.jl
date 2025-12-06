abstract type AbstractSystem{T} end
export AbstractSystem

"""
    AbstractDeterministicSystem{T} <: AbstractSystem{T}

Deterministic systems are mainly handled by this abstract type. It is intended to be used for models
"""
abstract type AbstractDeterministicSystem{T} <: AbstractSystem{T} end
export AbstractDeterministicSystem
"""
    AbstractODEModel{T} <: AbstractDeterministicSystem{T}

Abstract type for differential equation models. It is intended to be passed to `ode_solver()`.
For `params :: AbstractODEModel{T}`, a differential equation `params(t, x) -> dxdt` is defined,
where `(t, x)` are the variables.
"""
abstract type AbstractODEModel{T} <: AbstractDeterministicSystem{T} end
include("model/odemodel.jl")
export AbstractODEModel
"""
    AbstractMap{T} <: AbstractDeterministicSystem{T}

Abstract type for map models. It is intended to be passed to `map_solver()`.
For `params :: AbstractMap{T}`, a map `params(x) -> x_new` is defined,
where `x` is the current state and `x_new` is the next state.
"""
abstract type AbstractMap{T} <: AbstractDeterministicSystem{T} end
include("model/mapmodel.jl")
export AbstractMap

"""
    AbstractStochasticSystem{T} <: AbstractSystem{T}
Abstract type for stochastic systems. It is intended to be used for models
that employ stochastic methods such as the Metropolis algorithm or Gibbs sampling.
"""
abstract type AbstractStochasticSystem{T} <: AbstractSystem{T} end
export AbstractStochasticSystem

"""
    AbstractSDEModel{T} <: AbstractStochasticSystem{T}
Abstract type for stochastic differential equation models. It is intended to be passed to `sde_solver()`.
For `params :: AbstractSDEModel{T}`, a stochastic differential equation `params(t, x) -> (drift, diffusion)` is defined,
where `(t, x)` are the variables.
"""
abstract type AbstractSDEModel{T} <: AbstractStochasticSystem{T} end
