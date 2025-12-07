# Rössler System

## Mathematical Formulation

The Rössler attractor is a system of three non-linear ordinary differential equations originally studied by Otto Rössler in 1976. It is one of the simplest continuous dynamical systems that exhibits chaotic behavior.

### Equations

```math
\begin{aligned}
\frac{dx}{dt} &= -y - z \\
\frac{dy}{dt} &= x + ay \\
\frac{dz}{dt} &= b + z(x - c)
\end{aligned}
```

### Parameters

- `a`: Controls the dynamics in the xy-plane
- `b`: Lifting parameter
- `c`: Critical parameter that controls the onset of chaos

### Implementation

```julia
@kwdef struct Rossler <: AbstractODEModel{Float64}
    a::Float64 = 0.2
    b::Float64 = 0.2
    c::Float64 = 5.7
end
```

## Physical Interpretation

Unlike the Lorenz system which was derived from a physical model, the Rössler system was constructed to be the simplest possible chaotic system. It exhibits:

- **Folding and Stretching**: The hallmark of chaotic dynamics
- **Simpler Structure**: Easier to analyze than the Lorenz attractor
- **Single Band**: Unlike Lorenz, has a single-band structure

## Dynamical Properties

### Standard Parameters (a=0.2, b=0.2, c=5.7)

- **Attractor Type**: Chaotic strange attractor
- **Dimension**: Fractal dimension ≈ 1.99
- **Topology**: Single-band attractor with characteristic "bun" shape
- **Lyapunov Exponents**:
  - λ₁ ≈ 0.07 (positive, indicating chaos)
  - λ₂ ≈ 0 (neutral)
  - λ₃ ≈ -5.4 (negative, dissipation)

### Fixed Points

The system has two equilibrium points when c > a:

1. `(x*, y*, z*) where x* = (c - √(c² - 4ab))/2`
2. `(x*, y*, z*) where x* = (c + √(c² - 4ab))/2`

For standard parameters, these fixed points are unstable, leading to chaotic dynamics.

### Phase Space Structure

The Rössler attractor has a distinctive shape:
- Trajectories spiral outward in the xy-plane
- When reaching a certain height, they fold back
- Creates a layered, bun-like structure

## Bifurcation Behavior

As parameter `c` varies (with a=0.2, b=0.2):

- **c < 2.0**: Stable limit cycle
- **c ≈ 2.0-4.0**: Period-doubling route to chaos
- **c ≈ 4.0-5.7**: Chaotic behavior
- **c ≈ 5.7**: Characteristic "funnel" attractor
- **c > 6.0**: Periodic windows within chaotic regime

The Rössler system is particularly useful for studying the **period-doubling route to chaos**.

## Poincaré Section

The Rössler system is ideal for studying Poincaré sections because of its clear periodic-like structure:

```julia
# Poincaré section at y = 0
plane_normal = [0.0, 1.0, 0.0]
plane_point = [0.0, 0.0, 0.0]

section = poincare_section(model, x0, plane_normal, plane_point, 1000.0; 
                           direction=:positive)
```

The Poincaré map reveals:
- For periodic orbits: Discrete points
- For chaotic orbits: Strange attractor structure

## Example Usage

### Basic Simulation
```julia
using DynamicalModels

# Create the model with standard chaotic parameters
model = Rossler(a=0.2, b=0.2, c=5.7)

# Initial condition
x0 = [1.0, 1.0, 1.0]

# Integrate the system
# trajectory = solve(model, x0, (0.0, 200.0), 0.01)
```

### Computing Lyapunov Exponents
```julia
using DynamicalModels

model = Rossler()
x0 = [1.0, 1.0, 1.0]

# Calculate largest Lyapunov exponent
λ_max = lyapunov_exponent(model, x0, 0.1; warmup=1000, n_iterations=5000)
println("Largest Lyapunov exponent: ", λ_max)
# Expected: ≈ 0.07

# Calculate full spectrum
λs = lyapunov_spectrum(model, x0, 0.5; warmup=1000, n_iterations=2000)
println("Lyapunov spectrum: ", λs)
```

### Poincaré Map Visualization
```julia
using DynamicalModels

model = Rossler()
x0 = [1.0, 1.0, 1.0]

# Poincaré section at y = 0 (crossing in positive direction)
plane_normal = [0.0, 1.0, 0.0]
plane_point = [0.0, 0.0, 0.0]

# Get 2D projection onto x-z plane
x_coords, z_coords = poincare_map_2d(model, x0, (1, 3), 
                                      plane_normal, plane_point, 500.0;
                                      direction=:positive)

# Plot (x_coords, z_coords) to see the Poincaré map
```

### Studying Period-Doubling
```julia
using DynamicalModels

# Study different values of c
c_values = 2.0:0.1:6.0

for c in c_values
    model = Rossler(a=0.2, b=0.2, c=c)
    x0 = [1.0, 1.0, 1.0]
    
    # Calculate Lyapunov exponent
    λ = lyapunov_exponent(model, x0, 0.1; warmup=1000, n_iterations=2000)
    
    println("c = $c, λ = $λ")
    # λ < 0: periodic, λ ≈ 0: quasi-periodic, λ > 0: chaotic
end
```

### Return Map Analysis
```julia
using DynamicalModels

model = Rossler()
x0 = [1.0, 1.0, 1.0]

# Get Poincaré section points
plane_normal = [0.0, 1.0, 0.0]
plane_point = [0.0, 0.0, 0.0]

section = poincare_section(model, x0, plane_normal, plane_point, 1000.0;
                           direction=:positive)

# Extract x-coordinates for return map
x_n = [p[1] for p in section[1:end-1]]
x_n1 = [p[1] for p in section[2:end]]

# Plot (x_n, x_n1) to see the return map
```

## Comparison with Lorenz System

| Property | Rössler | Lorenz |
|----------|---------|--------|
| Number of equations | 3 | 3 |
| Typical LE (largest) | ≈ 0.07 | ≈ 0.9 |
| Attractor topology | Single band | Two-winged |
| Fractal dimension | ≈ 1.99 | ≈ 2.06 |
| Physical origin | Mathematical construction | Atmospheric convection |
| Complexity | Simpler | More complex |

## Applications

1. **Chaos Theory Education**: Simpler than Lorenz, ideal for teaching
2. **Chemical Kinetics**: Modeling oscillating reactions
3. **Secure Communications**: Chaos-based encryption
4. **Signal Processing**: Understanding chaotic time series
5. **Pattern Recognition**: Training on chaotic data

## Advantages for Study

The Rössler system is particularly valuable because:

1. **Simplicity**: Simpler than many other chaotic systems
2. **Clear Geometry**: Easier to visualize than Lorenz
3. **Poincaré Sections**: Excellent for studying maps
4. **Period-Doubling**: Classic example of route to chaos
5. **Controllability**: Easy to switch between periodic and chaotic regimes

## References

1. Rössler, O. E. (1976). "An Equation for Continuous Chaos". Physics Letters A.
2. Strogatz, S. H. (2015). "Nonlinear Dynamics and Chaos". Westview Press.
3. Alligood, K. T., Sauer, T. D., & Yorke, J. A. (1996). "Chaos: An Introduction to Dynamical Systems". Springer.

## See Also

- [Lorenz System](lorenz.md)
- [Van der Pol Oscillator](vanderpol.md)
- [Poincaré Sections](../analysis.md#poincare-sections)
