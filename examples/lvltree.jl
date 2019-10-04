using ClusterTrees
using StaticArrays
using CompScienceMeshes

const P = SVector{3,Float64}


mesh = meshsphere(1.0, 0.04)
# points = [rand(P) for i in 1:800]
points = vertices(mesh)
points = [cartesian(CompScienceMeshes.center(chart(mesh, c))) for c in cells(mesh)]

root_center = P(0,0,0)
root_size = 1.0
tree = ClusterTrees.LevelledTrees.LevelledTree(root_center, root_size, Int[])

smallest_box_size = 1.0 / 2.0^10
for i in 1:length(points)
    destination = (smallest_box_size = smallest_box_size, target_point = points[i])
    root_state = ClusterTrees.LevelledTrees.rootstate(tree, destination)
    ClusterTrees.update!(tree, root_state, i, destination) do tree, node, data
        push!(ClusterTrees.data(tree,node).values, data)
    end
end


num_bins = 64
bins = [P[] for i in 1:num_bins]

num_printed = 0
num_points = 0
num_nodes = length(tree.nodes)
for (i,node) in enumerate(ClusterTrees.DepthFirstIterator(tree, root(tree)))
    b = div((i-1)*num_bins, num_nodes) + 1
    append!(bins[b], points[ClusterTrees.data(tree,node).values])
    global num_printed += 1
    global num_points += length(data(tree,node).values)
end

ordered_points = reduce(append!, bins)
ordered_points = [p[i] for p in ordered_points, i = 1:3]
@assert num_printed == length(tree.nodes)
@show num_points
@show length(points)
@assert num_points == length(points)

num_points = 0
ordered_points = P[]
for b in ClusterTrees.LevelledTrees.LevelIterator(tree, length(tree.levels))
    global num_points += length(ClusterTrees.data(tree,b).values)
    append!(ordered_points, points[ClusterTrees.data(tree,b).values])
end
@assert num_points == length(points)

using Plots
plot()
for i in 1:length(bins)
    x = getindex.(bins[i],1)
    y = getindex.(bins[i],2)
    z = getindex.(bins[i],3)
    scatter!(x,y,z)
end
plot!(legend=false)
gui()
