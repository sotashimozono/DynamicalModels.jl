using DynamicalModels
using Documenter

# ドキュメントを生成する
makedocs(
    sitename = "DynamicalModels.jl",
    modules  = [DynamicalModels],
    pages    = [
        "Home" => "index.md",
        "Models" => [
            "Van der Pol Oscillator" => "models/vanderpol.md",
            "Lorenz System" => "models/lorenz.md",
            "Rössler System" => "models/rossler.md",
            "Hodgkin-Huxley Model" => "models/hodgkin-huxley.md",
        ],
        "Analysis Tools" => "analysis.md",
    ]
)

# GitHub Pagesにデプロイする（後述）
deploydocs(
    repo = "github.com/sotashimozono/DynamicalModels.jl.git",
)