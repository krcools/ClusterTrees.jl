using ClusterTrees
using StaticArrays
using CompScienceMeshes

const P = SVector{3,Float64}

mesh = meshsphere(1.0, 0.04)
points = [cartesian(CompScienceMeshes.center(chart(mesh, c))) for c in cells(mesh)]

function sort_sfc(points)

    ct, sz = CompScienceMeshes.boundingbox(points)
    tree = ClusterTrees.LevelledTrees.LevelledTree(ct, sz, Int[])

    smb = sz / 2^log(length(points)+1)
    for (i,pt) = enumerate(points)
        dest = (smallest_box_size=smb, target_point=pt)
        state = ClusterTrees.LevelledTrees.rootstate(tree, dest)
        ClusterTrees.update!(tree, state, i, dest) do tree, node, i
            push!(data(tree, node).values, i)
        end
    end

    sorted = Vector{Int}()
    for node in ClusterTrees.DepthFirstIterator(tree, root(tree))
        append!(sorted, data(tree,node).values)
    end

    return sorted
end

st = sort_sfc(points)
sorted_points = points[st]
