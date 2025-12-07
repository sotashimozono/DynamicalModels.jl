# DynamicalModels.jl Examples

This directory contains comprehensive example scripts demonstrating the analysis capabilities of DynamicalModels.jl.

## Running the Examples

Each example can be run independently:

```bash
julia --project=.. examples/lorenz_analysis.jl
julia --project=.. examples/rossler_analysis.jl
julia --project=.. examples/vanderpol_analysis.jl
julia --project=.. examples/hodgkin_huxley_analysis.jl
```

Or from within Julia:

```julia
using Pkg
Pkg.activate("..")  # Activate the DynamicalModels environment
include("examples/lorenz_analysis.jl")
```

## Available Examples

### 1. Lorenz System Analysis (`lorenz_analysis.jl`)

Comprehensive analysis of the Lorenz attractor including:
- **Lyapunov Exponents**: Calculation of largest exponent and full spectrum
- **Poincaré Sections**: Visualization of the strange attractor
- **Fractal Dimensions**: Kaplan-Yorke dimension estimation
- **Butterfly Effect**: Sensitivity to initial conditions

**Key Concepts**:
- Chaotic dynamics
- Strange attractors
- Dissipative systems

### 2. Rössler System Analysis (`rossler_analysis.jl`)

Analysis of the Rössler attractor focusing on:
- **Poincaré Sections**: Classic bun-shaped attractor
- **Return Maps**: One-dimensional maps from continuous flow
- **Period-Doubling**: Route to chaos as parameters vary
- **Comparison with Lorenz**: Simpler chaos example

**Key Concepts**:
- Period-doubling bifurcations
- Return maps
- Routes to chaos

### 3. Van der Pol Oscillator (`vanderpol_analysis.jl`)

Analysis of self-sustained oscillations:
- **Limit Cycles**: Stable periodic orbits
- **Damping Effects**: How ϵ parameter affects oscillations
- **Forced Oscillations**: Response to periodic driving
- **Applications**: Electronic and biological oscillators

**Key Concepts**:
- Limit cycles
- Self-sustained oscillations
- Relaxation oscillations

### 4. Hodgkin-Huxley Model (`hodgkin_huxley_analysis.jl`)

Neural excitability and action potentials:
- **Resting State**: Equilibrium analysis
- **Excitability**: Threshold behavior
- **Action Potentials**: Spike generation mechanism
- **F-I Curves**: Firing rate vs current
- **Phase Space**: 4D dynamical system

**Key Concepts**:
- Excitable systems
- All-or-none response
- Neural computation
- Nobel Prize winning model

## Analysis Techniques Demonstrated

All examples demonstrate the following analysis techniques:

### Lyapunov Exponents
```julia
λ_max = lyapunov_exponent(model, x0, time_step)
λs = lyapunov_spectrum(model, x0, time_step)
```

### Poincaré Sections
```julia
section = poincare_section(model, x0, plane_normal, plane_point, t_max)
x_coords, y_coords = poincare_map_2d(model, x0, (1, 2), 
                                      plane_normal, plane_point, t_max)
```

### Fractal Dimensions
```julia
D_KY = kaplan_yorke_dimension(lyapunov_exponents)
radii, C, dim = correlation_dimension(trajectory_points)
```

## Expected Outputs

### Lorenz System
- Largest Lyapunov exponent: ~0.9
- Kaplan-Yorke dimension: ~2.06
- Behavior: Chaotic

### Rössler System (c=5.7)
- Largest Lyapunov exponent: ~0.07
- Behavior: Chaotic
- Clear period-doubling route

### Van der Pol (ϵ=1.0)
- Largest Lyapunov exponent: ~0 (periodic)
- Behavior: Stable limit cycle

### Hodgkin-Huxley
- Behavior: Excitable (all-or-none)
- Action potential duration: ~2-3 ms
- Refractory period: ~2-5 ms

## Tips for Exploration

1. **Vary Parameters**: Try different parameter values to see how behavior changes
2. **Initial Conditions**: Experiment with different starting points
3. **Integration Time**: Longer integration reveals more structure
4. **Convergence**: Increase iterations for more accurate Lyapunov exponents

## Visualization Suggestions

While these examples don't generate plots (to avoid dependencies), you can visualize results using:

```julia
using Plots

# Poincaré section
scatter(x_coords, y_coords, label="Poincaré Section")

# Return map
scatter(x_n, x_n1, label="Return Map")

# Lyapunov spectrum
bar(1:length(λs), λs, label="Lyapunov Exponents")
```

## Further Reading

- See the [documentation](../docs/src/) for detailed model descriptions
- Check the [analysis tools documentation](../docs/src/analysis.md) for method details
- Refer to test files in `../test/analysis/` for more examples

## Contributing

Feel free to add more example scripts demonstrating:
- Other models in the package
- Advanced analysis techniques
- Comparison studies
- Real-world applications

## References

1. Strogatz, S. H. (2015). "Nonlinear Dynamics and Chaos"
2. Ott, E. (2002). "Chaos in Dynamical Systems"
3. Izhikevich, E. M. (2007). "Dynamical Systems in Neuroscience"
