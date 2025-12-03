using DynamicalModels
using Documenter

# ドキュメントを生成する
makedocs(
    sitename = "DynamicalModels.jl",
    modules  = [DynamicalModels],
    pages    = [
        "Home" => "index.md"
    ]
)

# GitHub Pagesにデプロイする（後述）
deploydocs(
    repo = "github.com/sotashimozono/DynamicalModels.jl.git",
)