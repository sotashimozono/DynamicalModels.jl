# test/integration/test_separation.jl
#
# 計算結果がコードリポジトリから分離されていることを検証する。
#
# 確認する内容:
#   1. DataVault が使う outdir はリポジトリ外 (mktempdir)
#   2. 実際に計算・保存できる
#   3. .done により冪等性が保証される (2回目は計算しない)
#   4. out/ に .jld2 が生成されるが git-tracked な src/ には存在しない
#   5. データを消去して再計算しても同じ結果が得られる

using DynamicalModels, DataVault, ParamIO, Test

const CONFIGS = joinpath(@__DIR__, "..", "..", "configs")

# ヘルパー: Lorenz の1 key を計算して保存
function compute_key!(vault, key)
    ρ     = Float64(key.params["system.rho"])
    model = Lorenz(; σ=10.0, ρ=ρ, β=8/3)
    λ     = lyapunov_exponent(model, [1.0, 1.0, 1.0], 0.1; warmup=100, n_iterations=500)
    DataVault.save!(vault, key, Dict("rho" => ρ, "lyapunov" => λ))
    mark_done!(vault, key; tag_value=λ)
    return λ
end

@testset "data separation: outdir is outside the repo" begin
    outdir = mktempdir()
    repo_root = joinpath(@__DIR__, "..", "..")
    vault = Vault(joinpath(CONFIGS, "lorenz.toml"); outdir=outdir)

    # outdir はリポジトリルートの外
    @test !startswith(abspath(outdir), abspath(repo_root))
end

@testset "data separation: .jld2 files exist only in outdir" begin
    outdir = mktempdir()
    vault  = Vault(joinpath(CONFIGS, "lorenz.toml"); outdir=outdir)
    key    = DataVault.keys(vault)[1]

    compute_key!(vault, key)

    # outdir 内に .jld2 が存在する
    jld2_in_out = filter(
        f -> endswith(f, ".jld2"),
        [joinpath(r, f) for (r, _, fs) in walkdir(outdir) for f in fs],
    )
    @test length(jld2_in_out) >= 1

    # src/ には .jld2 が一切ない
    src_dir = joinpath(@__DIR__, "..", "..", "src")
    jld2_in_src = filter(
        f -> endswith(f, ".jld2"),
        [joinpath(r, f) for (r, _, fs) in walkdir(src_dir) for f in fs],
    )
    @test isempty(jld2_in_src)
end

@testset "data separation: idempotency (.done skips recomputation)" begin
    outdir = mktempdir()
    vault  = Vault(joinpath(CONFIGS, "lorenz.toml"); outdir=outdir)
    key    = DataVault.keys(vault)[1]

    @test !is_done(vault, key)
    compute_key!(vault, key)
    @test is_done(vault, key)

    # 2回目は pending に出てこない
    pending_after = DataVault.keys(vault; status=:pending)
    @test key ∉ pending_after
end

@testset "data separation: reproducibility (delete & recompute)" begin
    outdir = mktempdir()
    vault  = Vault(joinpath(CONFIGS, "lorenz.toml"); outdir=outdir)
    key    = DataVault.keys(vault)[1]

    λ_first = compute_key!(vault, key)
    d_first = DataVault.load(vault, key)

    # outdir を丸ごと削除して再計算
    rm(outdir; recursive=true)
    mkpath(outdir)
    vault2 = Vault(joinpath(CONFIGS, "lorenz.toml"); outdir=outdir)
    λ_second = compute_key!(vault2, key)
    d_second = DataVault.load(vault2, key)

    # 同じ初期条件・パラメータなので同じ結果になる
    @test d_first["rho"]      == d_second["rho"]
    @test d_first["lyapunov"] ≈  d_second["lyapunov"]  atol=1e-6
end

@testset "data separation: config_snapshot.toml is in outdir, not in configs/" begin
    outdir = mktempdir()
    vault  = Vault(joinpath(CONFIGS, "lorenz.toml"); outdir=outdir)

    snapshot_in_out = joinpath(
        outdir, "data", vault.spec.study.project_name, "config_snapshot.toml",
    )
    @test isfile(snapshot_in_out)

    # configs/ ディレクトリ内に config_snapshot.toml は生成されない
    snapshot_in_configs = joinpath(CONFIGS, "config_snapshot.toml")
    @test !isfile(snapshot_in_configs)
end
