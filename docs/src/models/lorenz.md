# Lorenz System

## Mathematical Formulation

The Lorenz system is a set of three coupled ordinary differential equations originally studied by Edward Lorenz in 1963. It was derived from a simplified model of atmospheric convection and is one of the most famous examples of a chaotic system.

### Equations

```math
\begin{aligned}
\frac{dx}{dt} &= \sigma(y - x) \\
\frac{dy}{dt} &= x(\rho - z) - y \\
\frac{dz}{dt} &= xy - \beta z
\end{aligned}
```

### Parameters

- `σ` (sigma): Prandtl number, relates viscosity to thermal conductivity
- `ρ` (rho): Rayleigh number, measures the temperature difference driving convection
- `β` (beta): Geometric factor related to the physical dimensions of the system

### Implementation

```julia
@kwdef struct Lorenz <: AbstractODEModel{Float64}
    σ::Float64 = 10.0
    ρ::Float64 = 28.0
    β::Float64 = 8/3
end
```

## Physical Interpretation

The Lorenz system models **Rayleigh-Bénard convection** in a fluid layer heated from below:

- `x`: Proportional to the intensity of convective motion
- `y`: Proportional to the temperature difference between ascending and descending currents
- `z`: Proportional to the distortion of the vertical temperature profile from linearity

## Dynamical Properties

### Fixed Points

The system has three equilibrium points:

1. **Origin**: `(0, 0, 0)` - No convection
2. **C+**: `(√(β(ρ-1)), √(β(ρ-1)), ρ-1)` - Clockwise convection
3. **C-**: `(-√(β(ρ-1)), -√(β(ρ-1)), ρ-1)` - Counter-clockwise convection

For the standard parameters (σ=10, ρ=28, β=8/3), C+ and C- are unstable, leading to chaotic dynamics.

### Chaotic Regime

With standard parameters:

- **Attractor**: The famous "butterfly attractor" or Lorenz attractor
- **Dimension**: Fractal dimension ≈ 2.06 (Kaplan-Yorke dimension)
- **Lyapunov Exponents**:
  - λ₁ ≈ 0.9 (positive, indicating chaos)
  - λ₂ ≈ 0 (neutral direction)
  - λ₃ ≈ -14.6 (negative, indicating dissipation)
- **Sum of Lyapunov exponents**: Negative (dissipative system)

### Phase Space Structure

The attractor has a distinctive butterfly shape with two "wings" corresponding to rotation around the C+ and C- fixed points. Trajectories spiral outward from one wing, cross to the other wing, and repeat in a seemingly random but deterministic pattern.

## Bifurcation Behavior

As the Rayleigh number ρ varies:

- **ρ < 1**: Stable fixed point at origin (no convection)
- **1 < ρ < ρ_H ≈ 24.74**: Stable convection at C+ or C-
- **ρ > ρ_H**: Chaotic behavior (Lorenz attractor)

## Example Usage

### Basic Simulation
```julia
using DynamicalModels

# Create the model with standard parameters
model = Lorenz(σ=10.0, ρ=28.0, β=8/3)

# Initial condition
x0 = [1.0, 1.0, 1.0]

# Integrate the system
# trajectory = solve(model, x0, (0.0, 100.0), 0.01)
```

### Computing Lyapunov Exponents
```julia
using DynamicalModels

model = Lorenz()
x0 = [1.0, 1.0, 1.0]

# Calculate largest Lyapunov exponent
λ_max = lyapunov_exponent(model, x0, 0.1; warmup=1000, n_iterations=5000)
println("Largest Lyapunov exponent: ", λ_max)
# Expected: ≈ 0.9

# Calculate full spectrum
λs = lyapunov_spectrum(model, x0, 0.5; warmup=1000, n_iterations=2000)
println("Lyapunov spectrum: ", λs)
```

### Poincaré Section
```julia
using DynamicalModels

model = Lorenz()
x0 = [1.0, 1.0, 1.0]

# Poincaré section at z = 27 (near the center of the attractor)
plane_normal = [0.0, 0.0, 1.0]
plane_point = [0.0, 0.0, 27.0]

section = poincare_section(model, x0, plane_normal, plane_point, 1000.0)

# Plot the 2D projection
x_coords, y_coords = poincare_map_2d(model, x0, (1, 2), 
                                      plane_normal, plane_point, 1000.0)
```

### Fractal Dimension
```julia
using DynamicalModels

model = Lorenz()
x0 = [1.0, 1.0, 1.0]

# Calculate Lyapunov spectrum
λs = lyapunov_spectrum(model, x0, 0.5; warmup=1000, n_iterations=2000)

# Calculate Kaplan-Yorke dimension
D_KY = kaplan_yorke_dimension(λs)
println("Kaplan-Yorke dimension: ", D_KY)
# Expected: ≈ 2.06
```

## Sensitivity to Initial Conditions

The Lorenz system exhibits extreme sensitivity to initial conditions - a hallmark of chaotic systems. Two trajectories starting from nearly identical initial conditions will diverge exponentially:

```julia
using DynamicalModels

model = Lorenz()
x0_1 = [1.0, 1.0, 1.0]
x0_2 = [1.0, 1.0, 1.0001]  # Tiny perturbation

# Integrate both and observe divergence
# This demonstrates the "butterfly effect"
```

## Applications

1. **Meteorology**: Weather prediction and understanding atmospheric dynamics
2. **Fluid Dynamics**: Convection patterns in fluids
3. **Lasers**: Modeling chaotic behavior in laser systems
4. **Chemical Reactions**: Oscillating chemical reactions (Belousov-Zhabotinsky)
5. **Chaos Theory**: Fundamental example for teaching and research

## Historical Significance

- **1963**: Edward Lorenz discovers chaotic behavior while studying numerical weather prediction
- **Butterfly Effect**: Coined by Lorenz to describe sensitivity to initial conditions
- **Strange Attractor**: One of the first examples of a strange (chaotic) attractor
- **Deterministic Chaos**: Demonstrated that simple deterministic systems can exhibit unpredictable behavior

## References

1. Lorenz, E. N. (1963). "Deterministic Nonperiodic Flow". Journal of the Atmospheric Sciences.
2. Strogatz, S. H. (2015). "Nonlinear Dynamics and Chaos". Westview Press.
3. Sparrow, C. (1982). "The Lorenz Equations: Bifurcations, Chaos, and Strange Attractors". Springer.

## See Also

- [Rössler System](rossler.md)
- [Van der Pol Oscillator](vanderpol.md)
- [Analysis Tools](../analysis.md)
