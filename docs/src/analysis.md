# Analysis Tools

DynamicalModels.jl provides several tools for analyzing dynamical systems, including Lyapunov exponents, Poincaré sections, and fractal dimension calculations.

## Lyapunov Exponents

Lyapunov exponents quantify the rate of separation of infinitesimally close trajectories, providing a measure of chaos and predictability.

### Largest Lyapunov Exponent

```julia
lyapunov_exponent(model, x0, time_step; dt=0.01, warmup=1000, n_iterations=10000)
```

Calculates the largest Lyapunov exponent using the tangent space method.

#### Parameters
- `model`: The dynamical model
- `x0`: Initial condition vector
- `time_step`: Integration time per iteration
- `dt`: Time step for RK4 integration
- `warmup`: Number of warmup iterations
- `n_iterations`: Number of iterations for calculation

#### Returns
- Largest Lyapunov exponent (Float64)

#### Interpretation
- **λ > 0**: Chaotic behavior (nearby trajectories diverge exponentially)
- **λ ≈ 0**: Periodic or quasi-periodic behavior
- **λ < 0**: Stable fixed point (nearby trajectories converge)

#### Example
```julia
using DynamicalModels

model = Lorenz()
x0 = [1.0, 1.0, 1.0]

λ_max = lyapunov_exponent(model, x0, 0.1; warmup=1000, n_iterations=5000)
println("Largest Lyapunov exponent: ", λ_max)

if λ_max > 0
    println("System is chaotic")
    println("Lyapunov time: ", 1/λ_max)
end
```

### Full Lyapunov Spectrum

```julia
lyapunov_spectrum(model, x0, time_step; dt=0.01, warmup=1000, n_iterations=10000)
```

Calculates all Lyapunov exponents using QR decomposition.

#### Returns
- Vector of Lyapunov exponents (sorted in descending order)

#### Interpretation
For an n-dimensional system:
- Number of exponents = n
- Sum of exponents < 0: Dissipative system (volume contracts)
- Sum of exponents = 0: Conservative system (volume preserved)
- One zero exponent often indicates a periodic orbit

#### Example
```julia
using DynamicalModels

model = Lorenz()
x0 = [1.0, 1.0, 1.0]

λs = lyapunov_spectrum(model, x0, 0.5; warmup=1000, n_iterations=2000)
println("Lyapunov spectrum: ", λs)
println("Sum of exponents: ", sum(λs))

# For Lorenz with standard parameters:
# λ₁ ≈ 0.9 (positive - chaos)
# λ₂ ≈ 0.0 (neutral)
# λ₃ ≈ -14.6 (negative - dissipation)
```

## Poincaré Sections

Poincaré sections reduce the dimensionality of a dynamical system by recording where trajectories intersect a chosen hyperplane.

### Basic Poincaré Section

```julia
poincare_section(model, x0, plane_normal, plane_point, t_max; 
                dt=0.01, direction=:both)
```

Computes the intersection points of a trajectory with a hyperplane.

#### Parameters
- `model`: The dynamical model
- `x0`: Initial condition
- `plane_normal`: Normal vector to the section plane
- `plane_point`: A point on the section plane
- `t_max`: Maximum integration time
- `dt`: Time step for integration
- `direction`: `:positive`, `:negative`, or `:both` (crossing direction)

#### Returns
- Vector of intersection points (each point is a vector)

#### Example
```julia
using DynamicalModels

model = Lorenz()
x0 = [1.0, 1.0, 1.0]

# Poincaré section at z = 27
plane_normal = [0.0, 0.0, 1.0]
plane_point = [0.0, 0.0, 27.0]

section = poincare_section(model, x0, plane_normal, plane_point, 1000.0)

println("Number of crossings: ", length(section))
# For chaotic Lorenz, section reveals strange attractor structure
```

### 2D Poincaré Map

```julia
poincare_map_2d(model, x0, coord_indices, plane_normal, plane_point, t_max;
               dt=0.01, direction=:both)
```

Projects Poincaré section points onto specified coordinates.

#### Parameters
- `coord_indices`: Tuple `(i, j)` specifying which coordinates to extract

#### Returns
- Tuple `(x_coords, y_coords)` of coordinate vectors

#### Example
```julia
using DynamicalModels

model = Rossler()
x0 = [1.0, 1.0, 1.0]

# Poincaré section at y = 0
plane_normal = [0.0, 1.0, 0.0]
plane_point = [0.0, 0.0, 0.0]

# Project onto x-z plane
x_coords, z_coords = poincare_map_2d(model, x0, (1, 3), 
                                      plane_normal, plane_point, 500.0;
                                      direction=:positive)

# Plot the Poincaré map
# scatter(x_coords, z_coords)
```

## Fractal Dimensions

Fractal dimensions quantify the complexity and self-similarity of attractors.

### Kaplan-Yorke Dimension

```julia
kaplan_yorke_dimension(lyapunov_exponents)
```

Calculates the Kaplan-Yorke (Lyapunov) dimension from Lyapunov exponents.

#### Formula

```math
D_{KY} = j + \frac{\lambda_1 + \lambda_2 + \cdots + \lambda_j}{|\lambda_{j+1}|}
```

where j is the largest integer such that λ₁ + λ₂ + ... + λⱼ ≥ 0.

#### Parameters
- `lyapunov_exponents`: Vector of Lyapunov exponents (sorted descending)

#### Returns
- Kaplan-Yorke dimension (Float64)

#### Example
```julia
using DynamicalModels

model = Lorenz()
x0 = [1.0, 1.0, 1.0]

# Calculate Lyapunov spectrum
λs = lyapunov_spectrum(model, x0, 0.5; warmup=1000, n_iterations=2000)

# Calculate dimension
D_KY = kaplan_yorke_dimension(λs)
println("Kaplan-Yorke dimension: ", D_KY)

# For Lorenz attractor: D_KY ≈ 2.06
# Indicates fractal structure between 2D and 3D
```

### Correlation Dimension

```julia
correlation_dimension(points; r_min=0.01, r_max=10.0, n_r=50)
```

Estimates the correlation dimension using the Grassberger-Procaccia algorithm.

#### Parameters
- `points`: Vector of points (trajectory data)
- `r_min`: Minimum radius for correlation sum
- `r_max`: Maximum radius for correlation sum
- `n_r`: Number of radius values to test

#### Returns
- Tuple `(radii, correlation_sums, estimated_dimension)`

#### Example
```julia
using DynamicalModels

model = Lorenz()
x0 = [1.0, 1.0, 1.0]

# Generate trajectory
# trajectory = solve(model, x0, (0.0, 1000.0), 0.01)
# points = [trajectory[i] for i in 1:length(trajectory)]

# Calculate correlation dimension
# radii, C, dim = correlation_dimension(points)
# println("Correlation dimension: ", dim)
```

### Box-Counting Dimension

```julia
box_counting_dimension(trajectory, box_sizes=nothing)
```

Estimates the box-counting (capacity) dimension.

#### Parameters
- `trajectory`: Vector of points
- `box_sizes`: Vector of box sizes to test (auto-generated if not provided)

#### Returns
- Tuple `(box_sizes, N_boxes, estimated_dimension)`

#### Example
```julia
using DynamicalModels

# trajectory = ... # Your trajectory data

sizes, N, dim = box_counting_dimension(trajectory)
println("Box-counting dimension: ", dim)

# Plot log-log plot for verification
# loglog(1 ./ sizes, N)
```

## Practical Tips

### Choosing Parameters

1. **Warmup Period**:
   - Allow transients to decay
   - Typical: 500-2000 iterations
   - Longer for systems with slow dynamics

2. **Number of Iterations**:
   - More iterations = better accuracy
   - Typical: 2000-10000
   - Trade-off between accuracy and computation time

3. **Time Step**:
   - Smaller = more accurate but slower
   - Typical: 0.01-0.1
   - Should resolve fastest dynamics

### Interpreting Results

1. **Lyapunov Exponents**:
   - Check convergence by varying n_iterations
   - Sum should be negative for dissipative systems
   - Positive largest exponent indicates chaos

2. **Poincaré Sections**:
   - Fixed points → periodic orbits
   - Closed curves → tori (quasi-periodic)
   - Strange structure → chaos

3. **Fractal Dimensions**:
   - Non-integer → fractal attractor
   - Close to integer → smooth attractor
   - Compare different measures for consistency

## Common Patterns

### Identifying System Type

| Lyapunov Exponents | Poincaré Section | System Type |
|-------------------|------------------|-------------|
| All negative | Converging points | Stable fixed point |
| One zero, rest negative | Discrete points | Limit cycle |
| One zero, one positive | Strange attractor | Chaos |
| Two zero | Closed curve | Torus (quasi-periodic) |

### Chaos Checklist

A system is likely chaotic if:
- ✓ Largest Lyapunov exponent > 0
- ✓ Poincaré section shows fractal structure
- ✓ Sensitive dependence on initial conditions
- ✓ Fractal dimension is non-integer
- ✓ Broad-band power spectrum

## References

1. Ott, E. (2002). "Chaos in Dynamical Systems". Cambridge University Press.
2. Sprott, J. C. (2003). "Chaos and Time-Series Analysis". Oxford University Press.
3. Kantz, H., & Schreiber, T. (2004). "Nonlinear Time Series Analysis". Cambridge University Press.

## See Also

- [Lorenz System](models/lorenz.md)
- [Rössler System](models/rossler.md)
- [Van der Pol Oscillator](models/vanderpol.md)
