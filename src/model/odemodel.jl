"""
    HarmonicOscillator(; k=1.0, m=1.0)

単振動子のパラメータを保持する構造体。
`f(t, x)` の形式で `ode_solver` に渡すことができます。

- `k`: ばね定数
- `m`: 質量
"""
@kwdef struct HarmonicOscillator <: AbstractODEModel{Float64}
    k::Float64 = 1.0
    m::Float64 = 1.0
end
function (params::HarmonicOscillator)(t, x)
    k = params.k
    m = params.m
    dxdt = x[2]
    dydt = -k * x[1] / m
    return [dxdt, dydt]
end
export HarmonicOscillator
"""
    solve_exact(model::HarmonicOscillator, t, x0)

単振動子の厳密解を計算する関数。
`model` インスタンスからパラメータ `k`, `m` を使用する。

- `model`: `HarmonicOscillator` のインスタンス
- `t`: 時刻
- `x0`: 初期条件ベクトル `[位置, 速度]`

時刻がスカラーならその時刻の解を、ベクトルなら各時刻の解を返す。
"""
function solve_exact(model::HarmonicOscillator, t::Number, x0)
    (; k, m) = model
    ω = sqrt(k / m)
    A = x0[1]
    B = x0[2] / ω
    x = A * cos(ω * t) + B * sin(ω * t)
    y = -A * ω * sin(ω * t) + B * ω * cos(ω * t)
    return [x, y]
end
function solve_exact(model::HarmonicOscillator, t_list::AbstractVector, x0)
    return solve_exact.(Ref(model), t_list, Ref(x0))
end
export solve_exact
"""
    VanDerPol(; ϵ=1.0, F=0.0, ω=0.0)

Van der Pol方程式のパラメータ（ϵ版）を保持する構造体。

- `ϵ`: 非線形減衰の強さ
- `F`: 強制振動の振幅
- `ω`: 強制振動の角周波数
"""
@kwdef struct VanDerPol <: AbstractODEModel{Float64}
    ϵ::Float64 = 1.0
    F::Float64 = 0.0
    ω::Float64 = 0.0
end
function (params::VanDerPol)(t, x)
    ϵ, F, ω = params.ϵ, params.F, params.ω
    dxdt = x[2]
    dydt = (ϵ - x[1]^2) * x[2] - x[1] + F * sin(ω * t)
    return [dxdt, dydt]
end
export VanDerPol
"""
    VanDerPolMu(; μ=1.0, F=0.0, ω=0.0)

Van der Pol方程式のパラメータ（μ版）を保持する構造体。
適当な変数変換でϵ版に変換可能。

- `μ`: 非線形減衰の強さ (μ > 0)
- `F`: 強制振動の振幅
- `ω`: 強制振動の角周波数
"""
@kwdef struct VanDerPolMu <: AbstractODEModel{Float64}
    μ::Float64 = 1.0
    F::Float64 = 0.0
    ω::Float64 = 0.0
end
function (params::VanDerPolMu)(t, x)
    μ, F, ω = params.μ, params.F, params.ω
    dxdt = x[2]
    dydt = μ * (1 - x[1]^2) * x[2] - x[1] + F * sin(ω * t)
    return [dxdt, dydt]
end
export VanDerPolMu
"""
    Lorenz(; σ=10.0, ρ=28.0, β=8/3)

Lorenz方程式のパラメータを保持する構造体。
`f(t, x)` の形式で `ode_solver` に渡すことができます。

- `σ`: プラントル数
- `ρ`: レイリー数
- `β`: 幾何学的パラメータ
"""
@kwdef struct Lorenz <: AbstractODEModel{Float64}
    σ::Float64 = 10.0
    ρ::Float64 = 28.0
    β::Float64 = 8/3
end
function (params::Lorenz)(t, x)
    σ, ρ, β = params.σ, params.ρ, params.β
    
    dxdt = σ * (x[2] - x[1])
    dydt = x[1] * (ρ - x[3]) - x[2]
    dzdt = x[1] * x[2] - β * x[3]
    return [dxdt, dydt, dzdt]
end
export Lorenz
"""
    Rossler(; a=0.2, b=0.2, c=5.7)

Rossler方程式のパラメータを保持する構造体。
`f(t, x)` の形式で `ode_solver` に渡すことができます。

- `a`, `b`, `c`: システムパラメータ
"""
@kwdef struct Rossler <: AbstractODEModel{Float64}
    a::Float64 = 0.2
    b::Float64 = 0.2
    c::Float64 = 5.7
end
function (params::Rossler)(t, x)
    a, b, c = params.a, params.b, params.c
    dxdt = -x[2] - x[3]
    dydt = x[1] + a * x[2]
    dzdt = b + x[3] * (x[1] - c)
    return [dxdt, dydt, dzdt]
end
export Rossler
"""
    HodgkinHuxley(; C_m=1.0, ...)

Hodgkin-Huxleyモデルのニューロンパラメータを保持する構造体。
`f(t, data; I_ext_func=...)` の形式で `ode_solver` に渡すことができます。

- `C_m`: 膜容量 (μF/cm²)
- `V_Na`, `V_K`, `V_L`: 各イオンの平衡電位 (mV)
- `g_Na`, `g_K`, `g_L`: 各イオンの最大コンダクタンス (mS/cm²)
"""
@kwdef struct HodgkinHuxley <: AbstractODEModel{Float64}
    C_m::Float64 = 1.0
    V_Na::Float64 = 50.0
    V_K::Float64 = -77.0
    V_L::Float64 = -54.387
    g_Na::Float64 = 120.0
    g_K::Float64 = 36.0
    g_L::Float64 = 0.3
end
α_n(model::HodgkinHuxley, V) = 0.01 * (V + 55) / (1 - exp(-(V + 55) / 10))
β_n(model::HodgkinHuxley, V) = 0.125 * exp(-(V + 65) / 80)
α_m(model::HodgkinHuxley, V) = 0.1 * (V + 40) / (1 - exp(-(V + 40) / 10))
β_m(model::HodgkinHuxley, V) = 4.0 * exp(-(V + 65) / 18)
α_h(model::HodgkinHuxley, V) = 0.07 * exp(-(V + 65) / 20)
β_h(model::HodgkinHuxley, V) = 1 / (1 + exp(-(V + 35) / 10))
dndt(model::HodgkinHuxley, V, n) = α_n(model, V) * (1 - n) - β_n(model, V) * n
dmdt(model::HodgkinHuxley, V, m) = α_m(model, V) * (1 - m) - β_m(model, V) * m
dhdt(model::HodgkinHuxley, V, h) = α_h(model, V) * (1 - h) - β_h(model, V) * h
function _dvdt(model::HodgkinHuxley, n, m, h, V, I_ext)
    (; C_m, g_Na, g_K, g_L, V_Na, V_K, V_L) = model
    dvdt = 0.0
    dvdt += -g_Na * m^3 * h * (V - V_Na)
    dvdt += -g_K * n^4 * (V - V_K)
    dvdt += -g_L * (V - V_L)
    dvdt += I_ext
    dvdt *= (1 / C_m)
    return dvdt
end
"""
    (model::HodgkinHuxley)(t, data; I_ext_func=δ, I_ext_kwargs=(...))

Hodgkin-Huxleyモデルの `ode_solver` 用インターフェース。
`kwargs` として `I_ext_func` (電流の時間関数) と
`I_ext_kwargs` (その関数に渡すパラメータ) を受け取ります。
"""
function (model::HodgkinHuxley)(t, data; I_ext_func=δ, I_ext_kwargs=(I_ext=10.0, span=10))
    V, n, m, h = data
    I_ext_value = I_ext_func(t; I_ext_kwargs...)

    dV = dvdt(model, n, m, h, V, I_ext_value)
    dn = dndt(model, V, n)
    dm = dmdt(model, V, m)
    dh = dhdt(model, V, h)
    return [dV, dn, dm, dh]
end
export HodgkinHuxley
function get_hh_initial_state(model::HodgkinHuxley, V0)
    n0 = α_n(model, V0) / (α_n(model, V0) + β_n(model, V0))
    m0 = α_m(model, V0) / (α_m(model, V0) + β_m(model, V0))
    h0 = α_h(model, V0) / (α_h(model, V0) + β_h(model, V0))
    return [V0, n0, m0, h0]
end
export get_hh_initial_state
function δ(t; I_ext=10.0, span=10, kwargs...)
    return (t % span == 0) ? I_ext : 0.0
end
function I_steady(t; I_ext=10.0, kwargs...)
    return I_ext
end
