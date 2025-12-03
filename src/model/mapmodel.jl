"""
    LogisticMap(; r=3.5)

ロジスティック写像 `x_{n+1} = r x_n (1 - x_n)` のパラメータを保持する構造体。
`f(x)` の形式で `map_solver` に渡すことができます。

- `r`: 成長率パラメータ
"""
@kwdef struct LogisticMap <: AbstractMap{Float64}
    r::Float64 = 3.5
end
function (params::LogisticMap)(x)
    r = params.r
    return r * x * (1 - x)
end
export LogisticMap
"""
    HenonMap(; a=1.4, b=0.3)

エノン写像のパラメータを保持する構造体。
`f(x)` の形式で `map_solver` に渡すことができます。

- `a`, `b`: システムパラメータ
"""
@kwdef struct HenonMap <: AbstractMap{Float64}
    a::Float64 = 1.4
    b::Float64 = 0.3
end
function (params::HenonMap)(n, x)
    a, b = params.a, params.b
    x1 = 1 - a * x[1]^2 + x[2]
    x2 = b * x[1]
    return [x1, x2]
end
export HenonMap
"""
    StandardMap(; K=1.0)

標準写像（Chirikov-Taylor map）のパラメータを保持する構造体。
`f(x)` の形式で `map_solver` に渡すことができます。

- `K`: 非線形性の強さ (カオスパラメータ)
"""
@kwdef struct StandardMap <: AbstractMap{Float64}
    K::Float64 = 1.0
end
function (params::StandardMap)(n, x)
    K = params.K
    p_new = x[2] + (K / (2π)) * sin(2π * x[1])
    q_new = x[1] + p_new
    return [mod1(q_new, 1.0), mod1(p_new, 1.0)]
end
export StandardMap
"""
    CircleMap(; K=1.0, Ω=0.5)

サークル写像のパラメータを保持する構造体。
`f(x)` の形式で `map_solver` に渡すことができます。

- `K`: 非線形性の強さ
- `Ω`: 周波数比 (Winding number)
"""
@kwdef struct CircleMap <: AbstractMap{Float64}
    K::Float64 = 1.0
    Ω::Float64 = 0.5
end
function (params::CircleMap)(n, x)
    K, Ω = params.K, params.Ω
    θ_new = x[1] + Ω - (K / (2π)) * sin(2π * x[1])
    return [mod1(θ_new, 1.0)]
end
export CircleMap