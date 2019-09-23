module SimpleTrees

# using AbstractTrees
using ClusterTrees

struct TreeNode{T}
    num_children::Int
    data::T
end

struct SimpleTree{V <: (AbstractVector{N} where {N<:TreeNode})}
    nodes::V
end


struct ChildView{T} tree::T end
ClusterTrees.children(tree::SimpleTree, node) = ClusterTrees.ChildIterator(tree, node)
ClusterTrees.root(tree::SimpleTree) = 1
ClusterTrees.data(tree::SimpleTree, node) = tree.nodes[node].data
ClusterTrees.haschildren(tree::SimpleTree, node) = (tree.nodes[node].num_children > 0)

function Base.iterate(itr::ClusterTrees.ChildIterator{<:SimpleTree}, state=(0,itr.node+1))
    state[1] == itr.tree.nodes[itr.node].num_children && return nothing
    child = itr.tree.nodes[state[2]]
    newstate = (state[1] + child.num_children + 1, state[2] + child.num_children + 1)
    return state[2], newstate
end

Base.getindex(tree::SimpleTree, i::Int) = tree.nodes[i]

ClusterTrees.root(tree::ClusterTrees.Mutable{<:SimpleTree}) = [1]
ClusterTrees.data(tree::ClusterTrees.Mutable{<:SimpleTree}, node) = tree.tree.nodes[last(node)].data
ClusterTrees.children(tree::ClusterTrees.Mutable{<:SimpleTree}, node) = ClusterTrees.ChildIterator(tree, node)
ClusterTrees.haschildren(tree::ClusterTrees.Mutable{<:SimpleTree}, node) = (tree.tree.nodes[last(node)].num_children > 0)

start(itr::ClusterTrees.ChildIterator{ClusterTrees.Mutable{SimpleTree{N}}} where {N}) = 0
done(itr::ClusterTrees.ChildIterator{ClusterTrees.Mutable{SimpleTree{N}}} where {N}, state) = (state == itr.tree.tree.nodes[last(itr.node)].num_children)
function next(itr::ClusterTrees.ChildIterator{ClusterTrees.Mutable{SimpleTree{N}}} where {N}, state)
    parent_idx = last(itr.node)
    child_idx = parent_idx + state + 1
    child = itr.tree.tree.nodes[child_idx]
    [itr.node; child_idx], state + child.num_children + 1
end

Base.iterate(itr::ClusterTrees.ChildIterator{ClusterTrees.Mutable{SimpleTree{N}}} where {N},
    state = start(itr)) = done(itr, state) ? nothing : next(itr, state)

# function Base.iterate(itr::ClusterTrees.ChildIterator{ClusterTrees.Mutable{SimpleTree{N}}} where {N})
#     initial_state = 0
#     iterate(itr, initial_state)
# end
#
# function Base.iterate(itr::ClusterTrees.ChildIterator{ClusterTrees.Mutable{SimpleTree{N}}} where {N}, state)
#     state == itr.tree.tree.nodes[last(itr.node)].num_children && return nothing
#     parent_idx = last(itr.node)
#     child_idx = parent_idx + state + 1
#     child = itr.tree.tree.nodes[child_idx]
#     return [itr.node; child_idx], state + child.num_children + 1
# end


# function insert_child!(tree::ClusterTrees.Mutable{<:SimpleTree}, parent, data)
#     parent_idx = last(parent)
#     insert!(tree.tree.nodes, parent_idx+1, TreeNode(0,data))
#     for i in reverse(parent)
#         node = tree.tree.nodes[i]
#         tree.tree.nodes[i] = TreeNode(node.num_children+1, node.data)
#     end
# end

function insert!(itr::ClusterTrees.ChildIterator{ClusterTrees.Mutable{SimpleTree{N}}} where {N}, item, state)
    parent = itr.node
    parent_idx = last(parent)
    child_idx = parent_idx + state + 1
    insert!(itr.tree.tree.nodes, child_idx, TreeNode(0,item))
    for i in reverse(parent)
        node = itr.tree.tree.nodes[i]
        itr.tree.tree.nodes[i] = TreeNode(node.num_children+1, node.data)
    end
end

end # module SimpleTrees
