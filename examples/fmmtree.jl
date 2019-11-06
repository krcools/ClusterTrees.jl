import Pkg; Pkg.activate(@__DIR__)

using ClusterTrees
using StaticArrays
using CompScienceMeshes
using LinearAlgebra

const P = SVector{3,Float64}

mbs = 1.0 / 2^(5-1)
points = [
    point(1,1,0)-point(mbs, mbs, 0) / 2,
    point(-1,-1,0)+point(mbs, mbs, 0) / 2]


ct, sz = point(0,0,0), 1.0
tree = ClusterTrees.LevelledTrees.LevelledTree(ct, sz, Int[])

for (i,pt) in pairs(points)
    dest = (smallest_box_size=mbs, target_point=pt)
    state = ClusterTrees.LevelledTrees.rootstate(tree, dest)
    ClusterTrees.update!(tree, state, i, dest) do tree, node, i
        push!(data(tree, node).values, i)
    end
end

ClusterTrees.print_tree(tree, root(tree))
block_tree = ClusterTrees.BlockTrees.BlockTree(tree,tree)

function updatestate(block_tree, chd, par_state)
    d = ClusterTrees.data(block_tree, chd)
    test_sector  = d[1].sector
    trial_sector = d[2].sector
    cs1 = ClusterTrees.LevelledTrees.center_size(test_sector, par_state[1][1], par_state[1][2])
    cs2 = ClusterTrees.LevelledTrees.center_size(trial_sector, par_state[2][1], par_state[2][2])
    return (cs1,cs2)
end

function listnearfarinteractions(block_tree, block, state, adm, nears, fars, level)
    adm(block_tree, block, state) && (push!(fars[level], block); return)
    !ClusterTrees.haschildren(block_tree, block) && (push!(nears,block); return)
    for chd ∈ children(block_tree, block)
        chd_state = updatestate(block_tree, chd, state)
        listnearfarinteractions(block_tree, chd, chd_state, adm, nears, fars, level+1)
    end
end


function isfar(block_tree, block, state)
    η = 1.1
    test_state, trial_state = state
    test_center, test_size = test_state
    trial_center, trial_size = trial_state
    center_dist = norm(test_center-trial_center)
    @show center_dist, test_size, trial_size
    if (center_dist - sqrt(3)*(test_size+trial_size)) / (test_size+trial_size) > η
        return true
    else
        return false
    end
end

nears = []
num_levels = length(tree.levels)
fars = [[] for l in 1:num_levels]
root_state = ((tree.center,tree.halfsize),(tree.center,tree.halfsize))
root_level = 1
listnearfarinteractions(block_tree, root(block_tree),
    root_state, isfar,nears, fars, root_level)
