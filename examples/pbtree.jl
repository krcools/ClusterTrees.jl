using ClusterTrees
using StaticArrays

struct Data
    sector::Int
    values::Vector{Int}
end

Data(s=0) = Data(s, Int[])

function sector_center_size(pt, ct, hs)
    hs = hs / 2
    bl = SVector([x > y for (x,y) in zip(pt,ct)]...)
    ct = SVector([b ? y+hs : y-hs for (b,y) in zip(bl,ct)]...)
    sc = sum(b ? 2^(i-1) : 0 for (i,b) in enumerate(bl))
    return sc, ct, hs
end

c = SVector{3,Float64}(1,1,1)
p = SVector{3,Float64}(0,3,-2)

s, c2, h = sector_center_size(p, c, 1.0)
s == 2
c2 == SVector{3,Float64}(0.5,1.5,0.5)
h = 0.5

function lastnonemptychild(tree,node)
    @assert ClusterTrees.PointerBasedTrees.getnode(tree,node).first_child >= 1
    r = 0
    for chd in children(tree, node)
        if !(ClusterTrees.PointerBasedTrees.getnode(tree,chd).first_child < 1)
            r = chd
        end
    end
    return r
end


function lastchild(tree,node)
    @assert ClusterTrees.PointerBasedTrees.getnode(tree,node).first_child >= 1
    r = 0
    for chd in children(tree, node)
        r = chd
    end
    return r
end

struct Router{P,T}
    target_point::P
    smallest_box_size::T
end

function reached(tree, target, meta)
    sector, center, size = meta
    return size <= target.smallest_box_size
end

function directions(tree, target, meta)
    sector, center, size = meta
    return sector_center_size(target.target_point, center, size)
end

function isontherighttrack(tree, node, meta)
    sector, center, size = meta
    ClusterTrees.data(tree, node).sector == sector
end

import ClusterTrees: start, next, done

# function ClusterTrees.route!(tree::ClusterTrees.PointerBasedTrees.PointerBasedTree, state, target)

#     (parent, prev_fat_par, meta) = state
#     reached(tree, target, meta) && return state

#     meta = directions(tree, target, meta)
#     prev_fat_child = prev_fat_par < 1 ? 0 : lastnonemptychild(tree, prev_fat_par)

#     chds = children(tree, parent)
#     pos = start(chds)
#     while !done(chds, pos)
#         child, newpos = next(chds, pos)
#         isontherighttrack(tree, child, meta) && return (child, prev_fat_child, meta)
#         ClusterTrees.haschildren(tree, child) && (prev_fat_child = child)
#         pos = newpos
#     end

#     sector, center, size = meta
#     child = insert!(chds, Data(sector), pos)

#     return child, prev_fat_child, meta
# end


function ClusterTrees.route!(tree::ClusterTrees.PointerBasedTrees.PointerBasedTree, state, target)

    (parent, meta) = state
    reached(tree, target, meta) && return state

    meta = directions(tree, target, meta)
    chds = children(tree, parent)
    pos = start(chds)
    while !done(chds, pos)
        child, newpos = next(chds, pos)
        isontherighttrack(tree, child, meta) && return (child, meta)
        pos = newpos
    end

    sector, center, size = meta
    child = insert!(chds, Data(sector), pos)

    return child, meta
end

const N = ClusterTrees.PointerBasedTrees.Node{Data}
tree = ClusterTrees.PointerBasedTrees.PointerBasedTree(
    N[N(Data(), 0, 0, 0, 0)], 1)

function update!(f, tree::ClusterTrees.PointerBasedTrees.PointerBasedTree, i::Int, point, sms::Float64)
    router! = Router(point, sms)
    root_sector, root_center, root_size = 0, SVector{3,Float64}(0,0,0), 1.0
    root_meta = root_sector, root_center, root_size
    root_state = (root(tree), root_meta)
    ClusterTrees.update!(f, tree, root_state, i, router!)
end

using DelimitedFiles
Q = readdlm(joinpath(@__DIR__, "points.dlm"), Float64)
points = [SVector{3,Float64}(Q[i,:]) for i in axes(Q,1)]
num_points = length(points)

smallest_box_size = 0.2
f(tree, state, data) = push!(ClusterTrees.data(tree, state[1]).values, data)

for i in 1:num_points
    update!(tree, i, points[i], smallest_box_size) do tree, node, data
        push!(ClusterTrees.data(tree, node).values, data)
    end
end

ns = sum(length(data(tree,nd).values) for nd in ClusterTrees.DepthFirstIterator(tree, tree.root))
@assert ns == num_points

ClusterTrees.print_tree(tree)

num_printed = 0
for node in ClusterTrees.DepthFirstIterator(tree, tree.root)
    global num_printed += 1
end
@assert num_printed == length(tree.nodes)
