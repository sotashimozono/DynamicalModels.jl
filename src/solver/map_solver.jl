""""
    map_solver(f::AbstractMap, n_steps::Int, x_0)
離散力学系の写像を反復的に適用して、状態の軌道を計算する関数。
- f: AbstractMap 型の写像関数。
- n_steps: 反復回数。
- x_0: 初期状態ベクトル。
"""
function map_solver(f::AbstractMap, n_steps::Int, x_0)
    x_list = zeros(eltype(x_0), n_steps, length(x_0))
    x_list[1, :] = x_0
    
    for n in 1:(n_steps - 1)
        x = @view x_list[n, :]
        x_list[n+1, :] = f(n, x)
    end
    return x_list
end

export map_solver