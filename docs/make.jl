using DynamicalModels
using Documenter
using Literate
using Downloads

# ── Assets: favicon / logo from GitHub profile ────────────────────────────────

assets_dir = joinpath(@__DIR__, "src", "assets")
mkpath(assets_dir)
Downloads.download(
  "https://github.com/sotashimozono.png", joinpath(assets_dir, "favicon.ico")
)
Downloads.download("https://github.com/sotashimozono.png", joinpath(assets_dir, "logo.png"))

# ── Literate: tutorial scripts → markdown ─────────────────────────────────────

TUTORIALS_SRC = joinpath(@__DIR__, "src", "tutorials")
TUTORIALS_OUT = joinpath(@__DIR__, "src", "tutorials")

for script in filter(f -> endswith(f, ".jl"), readdir(TUTORIALS_SRC))
  Literate.markdown(
    joinpath(TUTORIALS_SRC, script),
    TUTORIALS_OUT;
    documenter=true,
    execute=true,
    credit=false,
  )
end

# ── Documenter ────────────────────────────────────────────────────────────────

makedocs(;
  sitename="DynamicalModels.jl",
  modules=[DynamicalModels],
  format=Documenter.HTML(;
    canonical="https://codes.sota-shimozono.com/DynamicalModels.jl/stable/",
    prettyurls=get(ENV, "CI", "false") == "true",
    mathengine=MathJax3(
      Dict(
        :tex => Dict(
          :inlineMath => [["\$", "\$"], ["\\(", "\\)"]],
          :tags => "ams",
          :packages => ["base", "ams", "autoload", "physics"],
        ),
      ),
    ),
    assets=["assets/favicon.ico"],
  ),
  pages=[
    "Home" => "index.md",
    "Models" => [
      "Van der Pol Oscillator" => "models/vanderpol.md",
      "Lorenz System" => "models/lorenz.md",
      "Rössler System" => "models/rossler.md",
      "Hodgkin-Huxley Model" => "models/hodgkin-huxley.md",
    ],
    "Analysis Tools" => "analysis.md",
    "Tutorials" => ["Parameter Space Management" => "tutorials/paramset.md"],
  ],
)

deploydocs(;
  repo="github.com/sotashimozono/DynamicalModels.jl.git",
  devbranch="main",
  target="build",
  push_preview=false,
)
