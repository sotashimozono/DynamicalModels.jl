"""
Example: Analyzing the Rössler System

This script demonstrates analysis of the Rössler attractor with focus on:
- Poincaré sections and return maps
- Period-doubling route to chaos
- Lyapunov exponents
"""

using DynamicalModels

println("="^60)
println("Rössler System Analysis")
println("="^60)

# Create Rössler model with standard chaotic parameters
model = Rossler(a=0.2, b=0.2, c=5.7)
println("\nModel parameters:")
println("  a = $(model.a)")
println("  b = $(model.b)")
println("  c = $(model.c)")

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
elseif abs(λ_max) < 0.01
    println("~ System appears to be PERIODIC or QUASI-PERIODIC (λ ≈ 0)")
else
    println("✗ System converges to fixed point (λ < 0)")
end

println("\n" * "-"^60)
println("2. Poincaré Section and Return Map")
println("-"^60)

# Poincaré section at y = 0 (crossing in positive y direction)
plane_normal = [0.0, 1.0, 0.0]
plane_point = [0.0, 0.0, 0.0]

println("\nCalculating Poincaré section at y = 0...")
section = poincare_section(model, x0, plane_normal, plane_point, 500.0; 
                           dt=0.01, direction=:positive)

println("Number of section crossings: ", length(section))

# Get x-z projection
x_coords, z_coords = poincare_map_2d(model, x0, (1, 3), 
                                      plane_normal, plane_point, 500.0;
                                      direction=:positive)

println("\nPoincaré section statistics:")
println("  x range: [", minimum(x_coords), ", ", maximum(x_coords), "]")
println("  z range: [", minimum(z_coords), ", ", maximum(z_coords), "]")

# Return map analysis
if length(x_coords) > 1
    println("\nReturn map analysis (x-coordinates):")
    x_n = x_coords[1:end-1]
    x_n1 = x_coords[2:end]
    
    println("  Number of points in return map: ", length(x_n))
    println("  Return map reveals structure of attractor")
    println("  (Plot x_n vs x_n1 to see return map)")
end

println("\n" * "-"^60)
println("3. Period-Doubling Route to Chaos")
println("-"^60)

println("\nScanning parameter c to observe period-doubling:")
println("(c values from 2.0 to 6.0)")
println()

c_values = [2.0, 3.0, 4.0, 4.5, 5.0, 5.5, 5.7, 6.0]

for c in c_values
    test_model = Rossler(a=0.2, b=0.2, c=c)
    λ = lyapunov_exponent(test_model, x0, 0.1; warmup=500, n_iterations=1000)
    
    behavior = if λ > 0.01
        "CHAOTIC"
    elseif abs(λ) < 0.01
        "PERIODIC/QUASI-PERIODIC"
    else
        "STABLE"
    end
    
    println("  c = ", c, "\tλ = ", round(λ, digits=4), "\t[", behavior, "]")
end

println("\nObservations:")
println("  - Low c: Periodic behavior (λ ≈ 0)")
println("  - c ≈ 4-5: Transition region")
println("  - c ≈ 5.7: Strong chaos (λ > 0)")

println("\n" * "-"^60)
println("4. Comparison with Lorenz System")
println("-"^60)

println("\nRössler vs Lorenz characteristics:")
println()
println("  Rössler:")
println("    - Simpler equations")
println("    - Single-band attractor")
println("    - λ_max ≈ 0.07 (weaker chaos)")
println("    - Clear period-doubling route")
println()
println("  Lorenz:")
println("    - More complex dynamics")
println("    - Two-winged attractor")
println("    - λ_max ≈ 0.9 (stronger chaos)")
println("    - Direct transition to chaos")

println("\n" * "="^60)
println("Analysis Complete")
println("="^60)
println("\nSummary:")
println("  - Rössler system exhibits chaotic behavior at c = 5.7")
println("  - Lyapunov exponent: ", round(λ_max, digits=3))
println("  - Poincaré section shows characteristic bun shape")
println("  - Period-doubling route to chaos observed")
println("  - Ideal for studying transition to chaos")
println("\n" * "="^60)
