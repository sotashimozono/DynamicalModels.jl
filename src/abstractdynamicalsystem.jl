abstract type AbstractSystem{T} end
export AbstractSystem

"""
    AbstractDeterministicSystem{T} <: AbstractSystem{T}

Deterministicな力学系を主に扱う抽象型。
"""
abstract type AbstractDeterministicSystem{T} <: AbstractSystem{T} end
export AbstractDeterministicSystem
"""
    AbstractODEModel{T} <: AbstractDeterministicSystem{T}

微分方程式モデルの抽象型。`ode_solver()` に渡すことを想定している。
`params :: AbstractODEModel{T}` に対しては `(t, x)` を変数として
受け取る微分方程式 `params(t, x) -> dxdt` を定義している。
"""
abstract type AbstractODEModel{T} <: AbstractDeterministicSystem{T} end
include("model/odemodel.jl")
export AbstractODEModel
"""
    AbstractMap{T} <: AbstractDeterministicSystem{T}

写像モデルの抽象型。`map_solver()` に渡すことを想定して、
`params :: AbstractMap{T}` に対して `(x)` を受け取ったときに
次の `x_new` を返す写像 `params(x) -> x_new` を定義している。
"""
abstract type AbstractMap{T} <: AbstractDeterministicSystem{T} end
include("model/mapmodel.jl")
export AbstractMap

"""
    AbstractStochasticSystem{T} <: AbstractSystem{T}
確率的な系を主に扱う抽象型。metropolis法やギブスサンプリングなどの
確率的手法で用いられるモデルに対して使用することを想定している。
"""
abstract type AbstractStochasticSystem{T} <: AbstractSystem{T} end
export AbstractStochasticSystem

"""
    AbstractSDEModel{T} <: AbstractStochasticSystem{T}
確率微分方程式モデルの抽象型。`sde_solver()` に渡すことを想定している。
`params :: AbstractSDEModel{T}` に対しては `(t, x)` を変数として
受け取る確率微分方程式 `params(t, x) -> (drift, diffusion)` を定義している。
"""
abstract type AbstractSDEModel{T} <: AbstractStochasticSystem{T} end
