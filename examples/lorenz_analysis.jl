"""
Example: Analyzing the Lorenz System

This script demonstrates comprehensive analysis of the Lorenz attractor including:
- Lyapunov exponent calculation
- Poincaré section visualization
- Fractal dimension estimation
"""

using DynamicalModels
using LinearAlgebra

println("="^60)
println("Lorenz System Analysis")
println("="^60)

# Create Lorenz model with standard parameters
model = Lorenz(σ=10.0, ρ=28.0, β=8/3)
println("\nModel parameters:")
println("  σ = $(model.σ)")
println("  ρ = $(model.ρ)")
println("  β = $(model.β)")

# Initial condition
x0 = [1.0, 1.0, 1.0]
println("\nInitial condition: ", x0)

println("\n" * "-"^60)
println("1. Lyapunov Exponent Analysis")
println("-"^60)

# Calculate largest Lyapunov exponent
println("\nCalculating largest Lyapunov exponent...")
λ_max = lyapunov_exponent(model, x0, 0.1; warmup=1000, n_iterations=5000)
println("Largest Lyapunov exponent: ", λ_max)

if λ_max > 0
    println("✓ System is CHAOTIC (λ > 0)")
    println("  Lyapunov time (predictability horizon): ", 1/λ_max, " time units")
else
    println("✗ System is NOT chaotic")
end

# Calculate full Lyapunov spectrum
println("\nCalculating full Lyapunov spectrum...")
println("(This may take a while...)")
λs = lyapunov_spectrum(model, x0, 0.5; warmup=1000, n_iterations=2000)
println("\nLyapunov spectrum:")
for (i, λ) in enumerate(λs)
    println("  λ[$i] = ", λ)
end

println("\nSpectrum interpretation:")
println("  Sum of exponents: ", sum(λs))
if sum(λs) < 0
    println("  ✓ Dissipative system (volume contracts)")
end

println("\n" * "-"^60)
println("2. Poincaré Section Analysis")
println("-"^60)

# Define Poincaré section at z = 27
plane_normal = [0.0, 0.0, 1.0]
plane_point = [0.0, 0.0, 27.0]

println("\nCalculating Poincaré section at z = 27...")
section = poincare_section(model, x0, plane_normal, plane_point, 500.0; 
                           dt=0.01, direction=:both)

println("Number of section crossings: ", length(section))

# Get 2D projection
x_coords, y_coords = poincare_map_2d(model, x0, (1, 2), 
                                      plane_normal, plane_point, 500.0)

println("\nPoincaré section statistics:")
println("  x range: [", minimum(x_coords), ", ", maximum(x_coords), "]")
println("  y range: [", minimum(y_coords), ", ", maximum(y_coords), "]")

println("\n" * "-"^60)
println("3. Fractal Dimension Analysis")
println("-"^60)

# Calculate Kaplan-Yorke dimension
D_KY = kaplan_yorke_dimension(λs)
println("\nKaplan-Yorke (Lyapunov) dimension: ", D_KY)
println("Expected for Lorenz attractor: ~2.06")

if D_KY > 2.0 && D_KY < 3.0
    println("✓ Fractal dimension confirms strange attractor")
    println("  (dimension between 2D surface and 3D volume)")
end

println("\n" * "-"^60)
println("4. Sensitivity to Initial Conditions")
println("-"^60)

# Compare two nearby trajectories
x0_1 = [1.0, 1.0, 1.0]
x0_2 = [1.0, 1.0, 1.0001]  # Tiny perturbation

println("\nDemonstrating butterfly effect:")
println("  Initial separation: ", norm(x0_2 - x0_1))

# Note: Full trajectory comparison would require implementing trajectory solver
println("  (Full trajectory comparison requires integration)")
println("  Expected: Exponential divergence with rate λ ≈ ", λ_max)

println("\n" * "="^60)
println("Analysis Complete")
println("="^60)
println("\nSummary:")
println("  - Lorenz system exhibits chaotic behavior")
println("  - Positive Lyapunov exponent: ", round(λ_max, digits=3))
println("  - Fractal dimension: ", round(D_KY, digits=3))
println("  - Poincaré section reveals strange attractor structure")
println("  - System is dissipative (volume contracts)")
println("\n" * "="^60)
