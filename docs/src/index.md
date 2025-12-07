# DynamicalModels.jl

Here is an implementation of DynamicalModels including Lorenz equation, Van der Pol equation, Hodgkin-Huxley model, and various analysis tools for studying chaotic and nonlinear dynamical systems.

## Overview

DynamicalModels.jl provides:

- **Classic Dynamical Systems**: Lorenz, Rössler, Van der Pol, Hodgkin-Huxley, and more
- **Analysis Tools**: Lyapunov exponents, Poincaré sections, fractal dimensions
- **Numerical Integration**: Built-in ODE and map solvers
- **Educational Resources**: Comprehensive documentation for each model

## Quick Start

### Basic Simulation

```julia
using DynamicalModels

# Create a Lorenz system
model = Lorenz(σ=10.0, ρ=28.0, β=8/3)

# Set initial condition
x0 = [1.0, 1.0, 1.0]

# Analyze the system
λ = lyapunov_exponent(model, x0, 0.1)
println("Largest Lyapunov exponent: ", λ)
```

### Poincaré Section

```julia
# Define Poincaré section
plane_normal = [0.0, 0.0, 1.0]
plane_point = [0.0, 0.0, 27.0]

section = poincare_section(model, x0, plane_normal, plane_point, 1000.0)
```

## Available Models

### Continuous Systems (ODEs)

- **[Van der Pol Oscillator](models/vanderpol.md)**: Self-sustained oscillations, limit cycles
- **[Lorenz System](models/lorenz.md)**: Classic chaotic attractor, atmospheric convection
- **[Rössler System](models/rossler.md)**: Simple chaotic system, period-doubling
- **[Hodgkin-Huxley Model](models/hodgkin-huxley.md)**: Neural action potentials, Nobel Prize model
- **Harmonic Oscillator**: Basic oscillations, exact solutions

### Discrete Systems (Maps)

- **Hénon Map**: 2D chaotic map
- **Logistic Map**: 1D chaos, bifurcation diagram
- **Standard Map**: Hamiltonian chaos
- **Circle Map**: Quasi-periodicity, winding numbers

## Analysis Capabilities

DynamicalModels.jl provides comprehensive tools for analyzing dynamical systems:

### [Lyapunov Exponents](analysis.md#lyapunov-exponents)

Measure chaos and predictability:
- Largest Lyapunov exponent
- Full Lyapunov spectrum
- Tangent space method with QR decomposition

### [Poincaré Sections](analysis.md#poincare-sections)

Reduce dimensionality and visualize attractors:
- Arbitrary hyperplane sections
- 2D projections
- Direction-sensitive crossing detection

### [Fractal Dimensions](analysis.md#fractal-dimensions)

Quantify attractor complexity:
- Kaplan-Yorke dimension
- Correlation dimension (Grassberger-Procaccia)
- Box-counting dimension

## Documentation Structure

```@contents
Pages = [
    "models/vanderpol.md",
    "models/lorenz.md",
    "models/rossler.md",
    "models/hodgkin-huxley.md",
    "analysis.md"
]
Depth = 2
```

## Examples

Each model documentation includes:
- Mathematical formulation
- Physical interpretation
- Dynamical properties
- Parameter guidelines
- Code examples
- Applications
- References

## API Reference

```@autodocs
Modules = [DynamicalModels]
```

## Contributing

Contributions are welcome! Please see the GitHub repository for more information.

## License

MIT License

## References

This package implements models and analysis methods from:

1. Strogatz, S. H. (2015). "Nonlinear Dynamics and Chaos". Westview Press.
2. Ott, E. (2002). "Chaos in Dynamical Systems". Cambridge University Press.
3. Izhikevich, E. M. (2007). "Dynamical Systems in Neuroscience". MIT Press.