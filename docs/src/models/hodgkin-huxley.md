# Hodgkin-Huxley Model

## Mathematical Formulation

The Hodgkin-Huxley model describes the dynamics of action potentials in neurons. Developed by Alan Hodgkin and Andrew Huxley in 1952 based on experiments on squid giant axons, it earned them the Nobel Prize in Physiology or Medicine in 1963.

### Equations

The model consists of four coupled differential equations:

```math
\begin{aligned}
C_m \frac{dV}{dt} &= -g_{Na}m^3h(V - V_{Na}) - g_K n^4(V - V_K) - g_L(V - V_L) + I_{ext} \\
\frac{dn}{dt} &= \alpha_n(V)(1-n) - \beta_n(V)n \\
\frac{dm}{dt} &= \alpha_m(V)(1-m) - \beta_m(V)m \\
\frac{dh}{dt} &= \alpha_h(V)(1-h) - \beta_h(V)h
\end{aligned}
```

### Variables

- `V`: Membrane potential (mV)
- `n`: Potassium channel activation gating variable (0 ≤ n ≤ 1)
- `m`: Sodium channel activation gating variable (0 ≤ m ≤ 1)
- `h`: Sodium channel inactivation gating variable (0 ≤ h ≤ 1)

### Parameters

- `C_m`: Membrane capacitance (μF/cm²)
- `g_Na, g_K, g_L`: Maximum conductances for Na⁺, K⁺, and leak channels (mS/cm²)
- `V_Na, V_K, V_L`: Reversal potentials for Na⁺, K⁺, and leak currents (mV)
- `I_ext`: External current stimulus (μA/cm²)

### Rate Functions

The voltage-dependent rate constants are:

```math
\begin{aligned}
\alpha_n(V) &= \frac{0.01(V+55)}{1-\exp(-(V+55)/10)} \\
\beta_n(V) &= 0.125\exp(-(V+65)/80) \\
\alpha_m(V) &= \frac{0.1(V+40)}{1-\exp(-(V+40)/10)} \\
\beta_m(V) &= 4.0\exp(-(V+65)/18) \\
\alpha_h(V) &= 0.07\exp(-(V+65)/20) \\
\beta_h(V) &= \frac{1}{1+\exp(-(V+35)/10)}
\end{aligned}
```

### Implementation

```julia
@kwdef struct HodgkinHuxley <: AbstractODEModel{Float64}
    C_m::Float64 = 1.0
    V_Na::Float64 = 50.0
    V_K::Float64 = -77.0
    V_L::Float64 = -54.387
    g_Na::Float64 = 120.0
    g_K::Float64 = 36.0
    g_L::Float64 = 0.3
end
```

## Physical Interpretation

The model represents the electrical behavior of a neuron membrane:

1. **Sodium Current** (`I_Na = g_Na m³h(V - V_Na)`):
   - Responsible for the rising phase of the action potential
   - `m³`: Three activation gates must open (fast)
   - `h`: One inactivation gate must be open (slower)

2. **Potassium Current** (`I_K = g_K n⁴(V - V_K)`):
   - Responsible for repolarization
   - `n⁴`: Four gates must open (delayed)

3. **Leak Current** (`I_L = g_L(V - V_L)`):
   - Passive current through non-gated channels

## Action Potential Dynamics

### Phases of an Action Potential

1. **Resting State** (V ≈ -65 mV):
   - n, m ≈ 0; h ≈ 1
   - Membrane at equilibrium

2. **Depolarization** (Rising phase):
   - Na⁺ channels open (m increases rapidly)
   - V rises sharply toward V_Na

3. **Peak** (V ≈ +40 mV):
   - Maximum sodium influx
   - Na⁺ inactivation begins (h decreases)

4. **Repolarization** (Falling phase):
   - K⁺ channels open (n increases)
   - Na⁺ channels inactivate
   - V decreases

5. **Hyperpolarization** (Undershoot):
   - K⁺ channels still open
   - V drops below resting potential

6. **Return to Rest**:
   - K⁺ channels close gradually
   - System returns to resting state

## Dynamical Properties

### Excitability

- **Threshold**: ~15-20 mV above resting potential
- **All-or-None**: Suprathreshold stimuli produce full action potentials
- **Refractory Period**: Period after spike when neuron cannot fire again

### Bifurcation Structure

As `I_ext` varies:

- **I_ext < I_threshold**: Stable resting state
- **I_ext = I_threshold**: Saddle-node bifurcation (excitability threshold)
- **I_ext > I_threshold**: Limit cycle oscillations (repetitive spiking)

### Phase Space (4D)

- **Dimension**: 4 (V, n, m, h)
- **Attractor Types**:
  - Stable fixed point (resting state)
  - Limit cycle (repetitive firing)
- **Separatrix**: Separates spiking from non-spiking trajectories

## Example Usage

### Single Action Potential
```julia
using DynamicalModels

# Create the model
model = HodgkinHuxley()

# Get initial state at resting potential
V0 = -65.0
x0 = get_hh_initial_state(model, V0)

# Short current pulse
I_ext_func(t; I_ext=10.0, span=1.0) = (0 < t < 1.0) ? I_ext : 0.0

# Simulate
# solution = solve(model, x0, (0.0, 50.0), 0.01; 
#                  I_ext_func=I_ext_func, I_ext_kwargs=(I_ext=10.0, span=1.0))
```

### Repetitive Firing
```julia
using DynamicalModels

model = HodgkinHuxley()
V0 = -65.0
x0 = get_hh_initial_state(model, V0)

# Constant current injection
I_steady(t; I_ext=10.0) = I_ext

# Simulate with sustained current
# solution = solve(model, x0, (0.0, 100.0), 0.01; 
#                  I_ext_func=I_steady, I_ext_kwargs=(I_ext=10.0,))
```

### F-I Curve (Frequency vs Current)
```julia
using DynamicalModels

model = HodgkinHuxley()

# Test different current levels
I_values = 0.0:1.0:20.0
frequencies = Float64[]

for I_ext in I_values
    V0 = -65.0
    x0 = get_hh_initial_state(model, V0)
    
    # Count spikes over time period
    # solution = solve(...)
    # freq = count_spikes(solution) / total_time
    # push!(frequencies, freq)
end

# Plot F-I curve: plot(I_values, frequencies)
```

### Phase Plane Analysis (V-n plane)
```julia
using DynamicalModels

model = HodgkinHuxley()

# For simplified analysis, often look at V-n subsystem
# m and h assumed to follow equilibrium values (fast-slow decomposition)

# Nullclines:
# dV/dt = 0: Cubic-shaped nullcline
# dn/dt = 0: Sigmoidal nullcline

# Intersection = fixed point
# Limit cycle wraps around fixed point when I_ext is above threshold
```

### Computing Lyapunov Exponents
```julia
using DynamicalModels

model = HodgkinHuxley()
V0 = -65.0
x0 = get_hh_initial_state(model, V0)

# Forrepetitive firing regime
I_steady(t; I_ext=10.0) = I_ext

# Wrap model to include current function
wrapped_model(t, x) = model(t, x; I_ext_func=I_steady, 
                             I_ext_kwargs=(I_ext=10.0,))

# Calculate Lyapunov exponents
# λs = lyapunov_spectrum(wrapped_model, x0, 0.5)
# For repetitive firing, expect one near-zero exponent (periodic orbit)
```

## Variations and Extensions

### Reduced Models

1. **FitzHugh-Nagumo**: 2D simplification
   - Captures essential excitable dynamics
   - Easier to analyze mathematically

2. **Morris-Lecar**: Alternative to HH
   - 2D model with similar properties
   - Different gating variables

### Modern Extensions

1. **Multi-compartment**: Spatially extended neurons
2. **Additional Channels**: Ca²⁺, various K⁺ subtypes
3. **Temperature Dependence**: Q10 factors for rate functions
4. **Stochastic Versions**: Channel noise

## Applications

1. **Neuroscience**: Understanding neural excitability
2. **Cardiac Electrophysiology**: Heart cell dynamics (modified versions)
3. **Drug Discovery**: Testing effects on ion channels
4. **Neural Prosthetics**: Designing stimulation protocols
5. **Computational Neuroscience**: Building neural network models

## Biological Significance

### Nobel Prize 1963

Hodgkin and Huxley's work:
- Explained the ionic basis of action potentials
- Introduced the concept of voltage-gated ion channels
- Established quantitative modeling in neuroscience

### Impact on Neuroscience

- **Foundation**: Basis for modern understanding of neuronal excitability
- **Predictive Power**: Accurately predicts experimental observations
- **Generality**: Framework extended to many cell types
- **Therapeutic**: Target for understanding neurological disorders

## Experimental Validation

The model was validated using:
- **Voltage Clamp**: Measuring currents at fixed voltages
- **Giant Squid Axon**: Large size allows precise measurements
- **Pharmacology**: Blocking specific channels (TTX for Na⁺, TEA for K⁺)

## Numerical Considerations

### Stiffness

The HH equations are **stiff** due to:
- Fast activation of sodium channels (m)
- Slower dynamics of other variables
- Requires small time steps or specialized solvers

### Initial Conditions

Use `get_hh_initial_state(model, V0)` to get consistent initial conditions:
- Gating variables at equilibrium for given voltage
- Avoids transient artifacts

## References

1. Hodgkin, A. L., & Huxley, A. F. (1952). "A Quantitative Description of Membrane Current and its Application to Conduction and Excitation in Nerve". Journal of Physiology.
2. Izhikevich, E. M. (2007). "Dynamical Systems in Neuroscience". MIT Press.
3. Keener, J., & Sneyd, J. (2009). "Mathematical Physiology". Springer.
4. Ermentrout, G. B., & Terman, D. H. (2010). "Mathematical Foundations of Neuroscience". Springer.

## See Also

- FitzHugh-Nagumo Model (not yet implemented)
- [Van der Pol Oscillator](vanderpol.md) - similar relaxation oscillations
- [Analysis Tools](../analysis.md)
