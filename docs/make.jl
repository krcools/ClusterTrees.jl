using Documenter, ClusterTrees
# using DocumenterMarkdown
makedocs(sitename="ClusterTrees Documentation", clean=false)

deploydocs(
    repo = "github.com/krcools/ClusterTrees.jl.git",
)
