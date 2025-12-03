# Available ODE solvers
"""
Euler method for solving ODEs.
error : O(h)
"""
function Euler(f, t, x, h; kwargs...)
    x_new = x .+ f(t, x; kwargs...) .* h
    return x_new
end
export Euler
"""
Heun's method (improved Euler method) for solving ODEs.
error : O(h^2)
"""
function Heun(f, t, x, h; kwargs...)
    k1 = f(t, x; kwargs...) .* h
    k2 = f(t + h, x .+ k1; kwargs...) .* h
    x_new = x .+ (1 / 2) .* (k1 .+ k2)
    return x_new
end
export Heun
"""
Mean Point method for solving ODEs.
error : O(h^2)
"""
function mean_point(f, t, x, h; kwargs...)
    k1 = f(t, x; kwargs...) .* h
    k2 = f(t + h / 2, x .+ k1 / 2; kwargs...) .* h
    x_new = x .+ k2
    return x_new
end
export mean_point
"""
Runge-Kutta 4th order method for solving ODEs.
error : O(h^4)
"""
function RK4(f, t, x, h; kwargs...)
    k1 = f(t, x; kwargs...) .* h
    k2 = f(t + h / 2, x .+ k1 / 2; kwargs...) .* h
    k3 = f(t + h / 2, x .+ k2 / 2; kwargs...) .* h
    k4 = f(t + h, x .+ k3; kwargs...) .* h
    x_new = x .+ (1 / 6) .* (k1 .+ 2 .* k2 .+ 2 .* k3 .+ k4)
    return x_new
end
export RK4

const ODE_SOLVERS = [
    Euler,
    Heun,
    mean_point,
    RK4,
]
const ODE_SOLVERS_STR = join(string.(ODE_SOLVERS), ", ")

"""
ode_solver can now handle systems of ODEs by working with vector-valued states. The individual solver functions ($(ODE_SOLVERS_STR)) have been implemented.  
This function is intended to solve
    ``dx/dt = f(t, x)``
where x can be a vector.
"""
function ode_solver(solver, f, t_list::AbstractVector, x_0; kwargs...)
    if !(solver in ODE_SOLVERS)
        error("Unknown ODE solver. Available solvers are: $(ODE_SOLVERS)")
    end
    x_list = zeros(eltype(x_0), length(t_list), size(x_0, 1))
    x_list[1, :] = x_0
    for i in 1:(length(t_list) - 1)
        x = @view x_list[i, :]
        t = t_list[i]
        h = t_list[i+1] - t_list[i]
        # update        
        x_list[i+1, :] = solver(f, t, x, h; kwargs...)
    end
    return x_list
end
export ode_solver