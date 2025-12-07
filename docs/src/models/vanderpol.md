# Van der Pol Oscillator

## Mathematical Formulation

The Van der Pol oscillator is a non-conservative oscillator with nonlinear damping. It was originally proposed by Balthasar van der Pol to model oscillations in vacuum tube circuits.

### Standard Form

The equation is given by:

```math
\frac{d^2x}{dt^2} - \mu(1 - x^2)\frac{dx}{dt} + x = F\sin(\omega t)
```

where:
- `μ` (or `ϵ`) is a parameter controlling the nonlinearity and strength of the damping
- `F` is the amplitude of the driving force
- `ω` is the angular frequency of the driving force

### State-Space Form

Converting to a system of first-order ODEs:

```math
\begin{aligned}
\frac{dx}{dt} &= y \\
\frac{dy}{dt} &= \mu(1 - x^2)y - x + F\sin(\omega t)
\end{aligned}
```

## Two Parametrizations in DynamicalModels.jl

### VanDerPol (ϵ version)
```julia
@kwdef struct VanDerPol <: AbstractODEModel{Float64}
    ϵ::Float64 = 1.0
    F::Float64 = 0.0
    ω::Float64 = 0.0
end
```

### VanDerPolMu (μ version)
```julia
@kwdef struct VanDerPolMu <: AbstractODEModel{Float64}
    μ::Float64 = 1.0
    F::Float64 = 0.0
    ω::Float64 = 0.0
end
```

The two versions are related by an appropriate variable transformation.

## Physical Interpretation

- When `μ > 0`, the system exhibits **self-sustained oscillations**
- For small `μ`, the oscillations are nearly sinusoidal
- For large `μ`, the oscillations become relaxation oscillations with a characteristic waveform
- The system has a **limit cycle** - a stable periodic orbit that attracts nearby trajectories

## Dynamical Properties

### Autonomous System (F = 0)

- **Fixed Point**: Origin (0, 0) is the only equilibrium point
- **Stability**: The origin is unstable for `μ > 0`
- **Limit Cycle**: A stable limit cycle exists around the origin
- **Lyapunov Exponents**: One exponent is zero (periodic orbit), one is negative (attracting)
- **Phase Space**: 2-dimensional

### Forced System (F ≠ 0)

The forced Van der Pol oscillator can exhibit:
- **Synchronization** with the driving force
- **Quasi-periodic** behavior
- **Chaotic** behavior for certain parameter combinations

## Typical Parameter Values

- `μ = 1.0`: Standard self-sustained oscillation
- `μ = 0.1`: Nearly harmonic oscillations
- `μ = 10.0`: Strong relaxation oscillations
- `F = 0.0, ω = 0.0`: Autonomous system
- `F = 5.0, ω = 2.466`: Parameters for studying forced oscillations

## Example Usage

### Basic Simulation
```julia
using DynamicalModels

# Create the model
model = VanDerPol(ϵ=1.0)

# Initial condition
x0 = [1.0, 0.0]

# Time parameters
t_span = (0.0, 50.0)
dt = 0.01

# Solve using RK4 (example - actual solver depends on implementation)
# trajectory = solve(model, x0, t_span, dt)
```

### Computing Lyapunov Exponents
```julia
using DynamicalModels

model = VanDerPol(ϵ=1.0)
x0 = [1.0, 0.0]

# Calculate largest Lyapunov exponent
λ_max = lyapunov_exponent(model, x0, 0.1)
println("Largest Lyapunov exponent: ", λ_max)

# For autonomous Van der Pol, expect λ_max ≈ 0 (limit cycle)
```

### Poincaré Section
```julia
using DynamicalModels

# Forced Van der Pol
model = VanDerPol(ϵ=1.0, F=5.0, ω=2.466)
x0 = [0.1, 0.0]

# Define Poincaré section (e.g., at x = 0)
plane_normal = [1.0, 0.0]
plane_point = [0.0, 0.0]

section = poincare_section(model, x0, plane_normal, plane_point, 1000.0)
```

## Applications

1. **Electrical Engineering**: Modeling oscillations in vacuum tubes and other electronic circuits
2. **Biology**: Modeling cardiac rhythms and neural oscillations
3. **Mechanics**: Modeling self-excited oscillations in mechanical systems
4. **Control Theory**: Studying nonlinear control systems

## References

1. van der Pol, B. (1926). "On Relaxation-Oscillations". The London, Edinburgh and Dublin Phil. Mag. & J. of Sci.
2. Strogatz, S. H. (2015). "Nonlinear Dynamics and Chaos". Westview Press.
3. Guckenheimer, J., & Holmes, P. (1983). "Nonlinear Oscillations, Dynamical Systems, and Bifurcations of Vector Fields". Springer.

## See Also

- [Lorenz System](lorenz.md)
- [Harmonic Oscillator](harmonic.md)
- [Analysis Tools](../analysis.md)
