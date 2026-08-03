# # Parameter Space Management with ParamIO and DataVault
#
# This tutorial demonstrates three patterns for defining parameter spaces in
# [ParamIO.jl](https://github.com/sotashimozono/ParamIO.jl), combined with
# [DataVault.jl](https://github.com/sotashimozono/DataVault.jl) for file management.
#
# All computations use `mktempdir()` so results are never committed to git —
# the docs are rebuilt fresh from code on every CI run.

ENV["GKSwstype"] = "100"   # headless Plots rendering

using DynamicalModels, DataVault, ParamIO, Printf, Plots

const CONFIGS = joinpath(@__DIR__, "..", "..", "..", "configs")
const OUTDIR = mktempdir()   # data lives here; thrown away after docs build

# ---
# ## Pattern 1 — Plain `path_keys`: Lorenz ρ sweep
#
# `σ` and `β` are fixed scalars; only `ρ` is swept.
# Writing `path_keys = ["rho"]` (plain leaf name) keeps paths short
# even though the TOML uses a `[paramsets.system]` sub-table.
#
# **Physical motivation**: the Lorenz system transitions from a fixed point
# to a chaotic attractor as ρ increases past ρ ≈ 24.74.

spec_lorenz = ParamIO.load(joinpath(CONFIGS, "lorenz.toml"))
println("path_keys : ", spec_lorenz.path_keys)
println("DataKeys  : ", length(ParamIO.expand(spec_lorenz)), " (param points × samples)")

vault_lorenz = Vault(joinpath(CONFIGS, "lorenz.toml"); outdir=joinpath(OUTDIR, "lorenz"))

for key in DataVault.keys(vault_lorenz; status=:pending)
  ρ = Float64(key.params["system.rho"])
  model = Lorenz(; σ=10.0, ρ=ρ, β=8/3)
  x0 = [1.0, 1.0, 1.0]
  λ = lyapunov_exponent(model, x0, 0.1; warmup=300, n_iterations=2000)
  DataVault.save!(vault_lorenz, key, Dict("rho" => ρ, "lyapunov" => λ))
  mark_done!(vault_lorenz, key; tag_value=λ)
end

println("\n| ρ     | λ (Lyapunov) | chaotic? |")
println("|-------|--------------|----------|")
seen = Set{Float64}()
rho_vals = Float64[]
lam_vals = Float64[]
for key in sort(DataVault.keys(vault_lorenz; status=:done); by=k->k.params["system.rho"])
  ρ = Float64(key.params["system.rho"])
  ρ ∈ seen && continue
  push!(seen, ρ)
  d = DataVault.load(vault_lorenz, key)
  push!(rho_vals, d["rho"])
  push!(lam_vals, d["lyapunov"])
  @printf(
    "| %5.2f | %12.4f | %-8s |\n", d["rho"], d["lyapunov"], d["lyapunov"] > 0 ? "yes" : "no"
  )
end

# The output path for each key:
k = DataVault.keys(vault_lorenz)[1]
println("\nExample path segment: ", ParamIO.format_path(k, spec_lorenz.path_keys))
println("(plain name → no group prefix)")

# ### Lorenz: Lyapunov exponent vs ρ
#
# The largest Lyapunov exponent crosses zero at ρ ≈ 24.74, marking the onset
# of chaos. Positive λ → exponential divergence of nearby trajectories.

p_lorenz = scatter(
  rho_vals,
  lam_vals;
  xlabel="ρ",
  ylabel="λ (Lyapunov exponent)",
  title="Lorenz system — λ vs ρ",
  legend=false,
  marker=(:circle, 8),
)
hline!(p_lorenz, [0.0]; linestyle=:dash, color=:gray, label="λ = 0")
annotate!(p_lorenz, 24.74, 0.05, text("ρ ≈ 24.74", 9, :left))
p_lorenz

# ---
# ## Pattern 2 — Multi-block union: Rössler bifurcation routes
#
# Two `[[paramsets]]` blocks define *independent* sweep directions.
# A full Cartesian product (5 × 5 = 25 points) would include physically
# meaningless combinations. The union gives exactly 5 + 5 = 10 points.
#
# - **Block 1**: sweep `a` along the period-doubling route (`c = 14.0` fixed)
# - **Block 2**: sweep `c` along the spiral→screw transition (`a = 0.2` fixed)

spec_rossler = ParamIO.load(joinpath(CONFIGS, "rossler.toml"))
println("\nRössler union: $(length(spec_rossler.paramsets)) blocks")
println(
  "Total points : $(length(ParamIO.expand(spec_rossler)) ÷ spec_rossler.study.total_samples) param points",
)
println("(vs Cartesian: $(5*5) points — most would be off the bifurcation paths)")

vault_rossler = Vault(joinpath(CONFIGS, "rossler.toml"); outdir=joinpath(OUTDIR, "rossler"))

for key in DataVault.keys(vault_rossler; status=:pending)
  a = Float64(key.params["system.a"])
  b = Float64(key.params["system.b"])
  c = Float64(key.params["system.c"])
  model = Rossler(; a=a, b=b, c=c)
  x0 = [1.0, 1.0, 1.0]
  λ = lyapunov_exponent(model, x0, 0.1; warmup=200, n_iterations=1500)
  DataVault.save!(vault_rossler, key, Dict("a" => a, "b" => b, "c" => c, "lyapunov" => λ))
  mark_done!(vault_rossler, key; tag_value=λ)
end

a_vals_r1 = Float64[];
lam_vals_r1 = Float64[]
c_vals_r2 = Float64[];
lam_vals_r2 = Float64[]

println("\nBlock 1 (c=14.0, a sweep — period-doubling route):")
println("| a    | λ      | chaotic? |")
println("|------|--------|----------|")
seen_r = Set{Tuple}()
for key in sort(
  DataVault.keys(vault_rossler; status=:done);
  by=k->(k.params["system.c"], k.params["system.a"]),
)
  d = DataVault.load(vault_rossler, key)
  t = (round(d["a"]; digits=3), round(d["c"]; digits=3))
  t ∈ seen_r && continue
  push!(seen_r, t)
  abs(d["c"] - 14.0) < 0.01 || continue
  push!(a_vals_r1, d["a"])
  push!(lam_vals_r1, d["lyapunov"])
  @printf(
    "| %.2f | %6.3f | %-8s |\n", d["a"], d["lyapunov"], d["lyapunov"] > 0 ? "yes" : "no"
  )
end

println("\nBlock 2 (a=0.2, c sweep — spiral→screw transition):")
println("| c    | λ      | chaotic? |")
println("|------|--------|----------|")
seen_r2 = Set{Tuple}()
for key in sort(DataVault.keys(vault_rossler; status=:done); by=k->k.params["system.c"])
  d = DataVault.load(vault_rossler, key)
  t = (round(d["a"]; digits=3), round(d["c"]; digits=3))
  t ∈ seen_r2 && continue
  push!(seen_r2, t)
  abs(d["a"] - 0.2) < 0.01 && abs(d["c"] - 14.0) > 0.1 || continue
  push!(c_vals_r2, d["c"])
  push!(lam_vals_r2, d["lyapunov"])
  @printf(
    "| %.1f | %6.3f | %-8s |\n", d["c"], d["lyapunov"], d["lyapunov"] > 0 ? "yes" : "no"
  )
end

# ### Rössler: Lyapunov exponents along two bifurcation routes
#
# The two panels show independent sweep directions.
# A Cartesian product would mix these routes, producing 25 physically irrelevant
# combinations. The union design captures exactly the two bifurcation paths.

p_r1 = scatter(
  a_vals_r1,
  lam_vals_r1;
  xlabel="a  (c = 14.0 fixed)",
  ylabel="λ",
  title="Rössler — period-doubling route",
  legend=false,
  marker=(:circle, 8),
)
hline!(p_r1, [0.0]; linestyle=:dash, color=:gray)

p_r2 = scatter(
  c_vals_r2,
  lam_vals_r2;
  xlabel="c  (a = 0.2 fixed)",
  ylabel="λ",
  title="Rössler — spiral→screw transition",
  legend=false,
  marker=(:diamond, 8),
)
hline!(p_r2, [0.0]; linestyle=:dash, color=:gray)

plot(p_r1, p_r2; layout=(1, 2), size=(820, 360))

# ---
# ## Pattern 3 — Config inheritance: Logistic map bifurcation diagram
#
# `chaos.toml` inherits `default.toml` and appends the chaos regime.
# This lets you run the base study first, then extend without recomputing.

spec_default = ParamIO.load(joinpath(CONFIGS, "logistic", "default.toml"))
spec_chaos = ParamIO.load(joinpath(CONFIGS, "logistic", "chaos.toml"))
println(
  "\nLogistic default : $(length(ParamIO.expand(spec_default))) DataKeys ($(spec_default.study.total_samples) sample)",
)
println(
  "Logistic chaos   : $(length(ParamIO.expand(spec_chaos))) DataKeys  (inherits default + adds chaos regime)",
)

vault_logistic = Vault(
  joinpath(CONFIGS, "logistic", "chaos.toml"); outdir=joinpath(OUTDIR, "logistic")
)

for key in DataVault.keys(vault_logistic; status=:pending)
  r = Float64(key.params["system.r"])
  n_iter = Int(key.params["system.n_iter"])
  n_skip = Int(key.params["system.n_skip"])

  model = LogisticMap(; r=r)
  x0 = [0.5]
  raw = map_solver(model, n_iter, x0)   # (n_iter × 1) matrix
  orbit = raw[:, 1]                       # 1-D time series
  attractor = orbit[(n_skip + 1):end]

  uniq = unique(round.(attractor; digits=4))
  period = length(uniq) > 50 ? Inf : length(uniq)

  DataVault.save!(
    vault_logistic, key, Dict("r" => r, "period" => period, "attractor" => attractor)
  )
  mark_done!(vault_logistic, key; tag_value=Float64(period))
end

println("\n| r    | period (approx) | regime        |")
println("|------|-----------------|---------------|")
seen_l = Set{Float64}()
for key in sort(DataVault.keys(vault_logistic; status=:done); by=k->k.params["system.r"])
  r = Float64(key.params["system.r"])
  r ∈ seen_l && continue
  push!(seen_l, r)
  d = DataVault.load(vault_logistic, key)
  p = d["period"]
  reg = if isinf(p)
    "chaotic"
  elseif p == 1
    "fixed point"
  else
    "period-$(Int(p))"
  end
  @printf("| %.2f | %-15s | %-13s |\n", r, isinf(p) ? "∞" : string(Int(p)), reg)
end

# ### Logistic map: bifurcation diagram
#
# Each vertical column of dots shows the long-run attractor for a given `r`.
# The period-doubling cascade and the onset of chaos at `r ≈ 3.57` are clearly visible.

r_plot = Float64[]
att_plot = Float64[]
for key in sort(DataVault.keys(vault_logistic; status=:done); by=k->k.params["system.r"])
  r = Float64(key.params["system.r"])
  r ∈ Set(r_plot) && continue
  d = DataVault.load(vault_logistic, key)
  for v in d["attractor"]
    push!(r_plot, r)
    push!(att_plot, v)
  end
end

scatter(
  r_plot,
  att_plot;
  xlabel="r",
  ylabel="x (attractor)",
  title="Logistic map — bifurcation diagram",
  markersize=1,
  markerstrokewidth=0,
  legend=false,
  alpha=0.3,
  size=(700, 400),
)

# ---
# ## Data separation summary
#
# All `.jld2` data files live in the `mktempdir()` directory — they are
# never in the git repository. The only things tracked by git are:
# - `configs/*.toml` — parameter definitions
# - `docs/src/tutorials/paramset.jl` — this script
# - `src/**/*.jl` — model implementations
#
# The ledger shows what was computed:

ledger = build_ledger(vault_lorenz)
println("\nLedger written to: $ledger")
println("(in mktempdir — not in git)")
