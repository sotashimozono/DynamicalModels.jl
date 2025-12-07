"""
Example: Analyzing the Van der Pol Oscillator

This script demonstrates analysis of the Van der Pol oscillator:
- Limit cycle behavior
- Effect of damping parameter
- Forced oscillations
"""

using DynamicalModels

println("="^60)
println("Van der Pol Oscillator Analysis")
println("="^60)

println("\n" * "-"^60)
println("1. Autonomous System (No Forcing)")
println("-"^60)

# Standard Van der Pol with moderate damping
model = VanDerPol(ϵ=1.0, F=0.0, ω=0.0)
println("\nModel parameters:")
println("  ϵ (damping) = $(model.ϵ)")
println("  F (forcing amplitude) = $(model.F)")
println("  ω (forcing frequency) = $(model.ω)")

x0 = [1.0, 0.0]
println("\nInitial condition: ", x0)

# Lyapunov exponent for limit cycle
println("\nCalculating Lyapunov exponent...")
λ_max = lyapunov_exponent(model, x0, 0.1; warmup=1000, n_iterations=3000)
println("Largest Lyapunov exponent: ", λ_max)

println("\nInterpretation:")
if abs(λ_max) < 0.1
    println("  ✓ λ ≈ 0: System exhibits LIMIT CYCLE behavior")
    println("  - Trajectories converge to a stable periodic orbit")
    println("  - Neither chaotic nor convergent to fixed point")
else
    println("  Note: λ should be ≈ 0 for limit cycle")
    println("  (May need more iterations for convergence)")
end

println("\n" * "-"^60)
println("2. Effect of Damping Parameter ϵ")
println("-"^60)

println("\nComparing different damping strengths:")
println()

ϵ_values = [0.1, 1.0, 5.0, 10.0]

for ϵ in ϵ_values
    test_model = VanDerPol(ϵ=ϵ)
    λ = lyapunov_exponent(test_model, x0, 0.1; warmup=500, n_iterations=1000)
    
    oscillation_type = if ϵ < 0.5
        "Nearly sinusoidal"
    elseif ϵ < 3.0
        "Moderate nonlinearity"
    else
        "Relaxation oscillations"
    end
    
    println("  ϵ = ", ϵ, "\tλ ≈ ", round(λ, digits=4), "\t[", oscillation_type, "]")
end

println("\nObservations:")
println("  - Small ϵ: Nearly harmonic oscillations")
println("  - Large ϵ: Sharp relaxation oscillations")
println("  - All cases: Stable limit cycle (λ ≈ 0)")

println("\n" * "-"^60)
println("3. Forced Van der Pol Oscillator")
println("-"^60)

# Forced oscillator
forced_model = VanDerPol(ϵ=1.0, F=5.0, ω=2.466)
println("\nForced oscillator parameters:")
println("  ϵ = $(forced_model.ϵ)")
println("  F = $(forced_model.F)")
println("  ω = $(forced_model.ω)")

println("\nNote: Forced Van der Pol can exhibit:")
println("  - Synchronization (locking to driving frequency)")
println("  - Quasi-periodic behavior")
println("  - Chaos (for certain parameter combinations)")

# For forced system, we would need to modify the analysis
# because the model now depends explicitly on time
println("\n(Full analysis of forced system requires time-dependent treatment)")

println("\n" * "-"^60)
println("4. Comparison with Other Oscillators")
println("-"^60)

println("\nVan der Pol vs Harmonic Oscillator:")
println()
println("  Van der Pol:")
println("    - Nonlinear damping: ϵ(1 - x²)ẋ")
println("    - Self-sustained oscillations")
println("    - Amplitude regulated by nonlinearity")
println("    - Limit cycle attractor")
println()
println("  Harmonic:")
println("    - Linear restoring force")
println("    - Energy conserved (no damping)")
println("    - Amplitude depends on initial conditions")
println("    - All orbits are closed curves")

println("\n" * "-"^60)
println("5. Physical Applications")
println("-"^60)

println("\nThe Van der Pol equation models:")
println()
println("  1. Electronic Circuits:")
println("     - Vacuum tube oscillators")
println("     - Tunnel diode circuits")
println()
println("  2. Biology:")
println("     - Cardiac pacemaker cells")
println("     - Neural oscillations")
println("     - Circadian rhythms")
println()
println("  3. Mechanical Systems:")
println("     - Clock escapements")
println("     - Violin string vibrations")

println("\n" * "="^60)
println("Analysis Complete")
println("="^60)
println("\nSummary:")
println("  - Van der Pol oscillator exhibits limit cycle behavior")
println("  - Lyapunov exponent ≈ 0 (periodic orbit)")
println("  - Parameter ϵ controls oscillation character")
println("  - Self-sustained oscillations independent of initial conditions")
println("  - Important model for biological and electronic oscillators")
println("\n" * "="^60)
