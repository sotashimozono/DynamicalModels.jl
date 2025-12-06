""""
    map_solver(f::AbstractMap, n_steps::Int, x_0)
Map solver for discrete-time dynamical systems.
- f: AbstractMap 
- n_steps: Number of iterations.
- x_0: Initial state vector.
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