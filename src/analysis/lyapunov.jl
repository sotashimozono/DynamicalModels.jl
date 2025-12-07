"""
    lyapunov_exponent(model, x0, time_step; dt=0.01, warmup=1000, n_iterations=10000)

Calculate the largest Lyapunov exponent for a continuous dynamical system.

# Arguments
- `model`: The dynamical model (must be callable with signature `model(t, x)`)
- `x0`: Initial condition vector
- `time_step`: Total integration time per iteration
- `dt`: Time step for integration (default: 0.01)
- `warmup`: Number of warmup iterations before calculating exponent (default: 1000)
- `n_iterations`: Number of iterations for calculation (default: 10000)

# Returns
- Largest Lyapunov exponent

# Example
```julia
model = Lorenz()
x0 = [1.0, 1.0, 1.0]
λ = lyapunov_exponent(model, x0, 0.1)
```
"""
function lyapunov_exponent(model, x0::AbstractVector{T}, time_step::Real; 
                          dt=0.01, warmup=1000, n_iterations=10000) where T
    dim = length(x0)
    x = copy(x0)
    δx = randn(T, dim)
    δx = δx / norm(δx) * 1e-8  # Small perturbation
    
    # Warmup phase
    for _ in 1:warmup
        x, _ = rk4_step(model, 0.0, x, time_step, dt)
        δx_evolved, _ = rk4_step(model, 0.0, x + δx, time_step, dt)
        δx = δx_evolved - x
        δx = δx / norm(δx) * 1e-8
    end
    
    # Calculation phase
    sum_log = 0.0
    for _ in 1:n_iterations
        x_new, _ = rk4_step(model, 0.0, x, time_step, dt)
        δx_evolved, _ = rk4_step(model, 0.0, x + δx, time_step, dt)
        δx_new = δx_evolved - x_new
        
        d = norm(δx_new)
        sum_log += log(d / 1e-8)
        
        x = x_new
        δx = δx_new / d * 1e-8
    end
    
    return sum_log / (n_iterations * time_step)
end
export lyapunov_exponent

"""
    lyapunov_spectrum(model, x0, time_step; dt=0.01, warmup=1000, n_iterations=10000)

Calculate the full Lyapunov spectrum for a continuous dynamical system using QR decomposition.

# Arguments
- `model`: The dynamical model
- `x0`: Initial condition vector
- `time_step`: Total integration time per iteration
- `dt`: Time step for integration (default: 0.01)
- `warmup`: Number of warmup iterations (default: 1000)
- `n_iterations`: Number of iterations for calculation (default: 10000)

# Returns
- Vector of Lyapunov exponents (sorted in descending order)
"""
function lyapunov_spectrum(model, x0::AbstractVector{T}, time_step::Real;
                          dt=0.01, warmup=1000, n_iterations=10000) where T
    dim = length(x0)
    x = copy(x0)
    
    # Initialize orthonormal perturbation vectors
    Q = Matrix{T}(I, dim, dim)
    
    # Warmup
    for _ in 1:warmup
        x, _ = rk4_step(model, 0.0, x, time_step, dt)
        # Evolve perturbation vectors
        Q_evolved = zeros(T, dim, dim)
        for j in 1:dim
            Q_evolved[:, j], _ = rk4_step(model, 0.0, x + Q[:, j] * 1e-8, time_step, dt)
            Q_evolved[:, j] = Q_evolved[:, j] - x
        end
        Q, _ = qr(Q_evolved)
    end
    
    # Calculation
    sum_log = zeros(T, dim)
    for _ in 1:n_iterations
        x_new, _ = rk4_step(model, 0.0, x, time_step, dt)
        
        # Evolve perturbation vectors
        Q_evolved = zeros(T, dim, dim)
        for j in 1:dim
            Q_evolved[:, j], _ = rk4_step(model, 0.0, x + Q[:, j] * 1e-8, time_step, dt)
            Q_evolved[:, j] = Q_evolved[:, j] - x_new
        end
        
        # QR decomposition
        Q_new, R = qr(Q_evolved)
        
        # Accumulate logarithms of diagonal elements
        for j in 1:dim
            sum_log[j] += log(abs(R[j, j]))
        end
        
        x = x_new
        Q = Matrix(Q_new)
    end
    
    λs = sum_log / (n_iterations * time_step)
    return sort(λs, rev=true)
end
export lyapunov_spectrum

"""
    rk4_step(f, t, x, T, dt)

Perform Runge-Kutta 4th order integration for time T with step dt.

Internal helper function for Lyapunov exponent calculations.
"""
function rk4_step(f, t::Real, x::AbstractVector{T}, total_time::Real, dt::Real) where T
    n_steps = Int(round(total_time / dt))
    current_t = t
    current_x = copy(x)
    
    for _ in 1:n_steps
        k1 = f(current_t, current_x)
        k2 = f(current_t + dt/2, current_x + dt/2 * k1)
        k3 = f(current_t + dt/2, current_x + dt/2 * k2)
        k4 = f(current_t + dt, current_x + dt * k3)
        
        current_x = current_x + (dt/6) * (k1 + 2*k2 + 2*k3 + k4)
        current_t += dt
    end
    
    return current_x, current_t
end
