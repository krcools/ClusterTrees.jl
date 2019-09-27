module PointerBasedTrees
using ClusterTrees

import ClusterTrees.ChildIterator
import ClusterTrees: start, next, done

mutable struct Node{T}
    data::T
    num_children::Int
    next_sibling::Int
    parent::Int
    first_child::Int
end

data(n::Node) = n.data

abstract type APBTree end
struct PointerBasedTree{N<:Node} <: APBTree
    nodes::Vector{N}
    root::Int
end

getnode(tree::PointerBasedTree, node_idx) = tree.nodes[node_idx]
nextsibling(tree::PointerBasedTree, node_idx) = getnode(tree, node_idx).next_sibling
parent(tree::PointerBasedTree, node_idx) = getnode(tree, node_idx).parent
firstchild(tree::PointerBasedTree, node_idx) = getnode(tree, node_idx).first_child

start(itr::ChildIterator{<:APBTree}) = (0, firstchild(itr.tree, itr.node))
function done(itr::ChildIterator{<:APBTree}, state)
    prev, this = state
    this < 1 && return true
    sibling_par = parent(itr.tree, this)
    sibling_par != itr.node && return true
    return false
end

function next(itr::ChildIterator{<:APBTree}, state)
    prev, this = state
    nxt = nextsibling(itr.tree, this)
    return (this, (this, nxt))
end

# Base.iterate(itr::ChildIterator) = iterate(itr, firstchild(itr.tree, itr.node))
# function Base.iterate(itr::ChildIterator, state)
#     # Check if state is a valid node pointer
#     state < 1 && return nothing
#     # If yes, check that the parent of the corresponding node equals
#     # the original parent. If not, we are looking at a distant *cousin*
#     sibling_par = parent(itr.tree, state)
#     sibling_par != itr.node && return nothing
#     sibling_idx = nextsibling(itr.tree, state)
#     return (state, sibling_idx)
# end

Base.iterate(itr::ChildIterator{<:APBTree}, st = start(itr)) = done(itr,st) ? nothing : next(itr,st)

Base.IteratorSize(cv::ChildIterator) = Base.SizeUnknown()

ClusterTrees.root(tree::PointerBasedTree) = tree.root
ClusterTrees.children(tree::APBTree, node=ClusterTrees.root(tree)) = ChildIterator(tree, node)
ClusterTrees.haschildren(tree::APBTree, node) = (firstchild(tree,node) >= 1)
ClusterTrees.data(tree::PointerBasedTree, node=ClusterTrees.root(tree)) = data(getnode(tree, node))

"""
    insert!(tree, parent, data)

Insert a node carrying `data` as the first child of `parent`
"""
function ClusterTrees.insert!(tree::PointerBasedTree, parent_idx, data)
    next = firstchild(tree, parent_idx)
    ClusterTrees.insert!(tree, data, parent=parent_idx, next=next, prev=0)
end


setfirstchild!(node::Node, child) = Node(node.data, node.num_children, node.next_sibling, node.parent, child)
setfirstchild!(tree::PointerBasedTree, node, child) = tree.nodes[node] = setfirstchild!(getnode(tree, node), child)

setnextsibling!(node::Node, next) = Node(node.data, node.num_children, next, node.parent, node.first_child)
setnextsibling!(tree::PointerBasedTree, node, next) = tree.nodes[node] = setnextsibling!(getnode(tree, node), next)

"""
    insert!(tree, data, before=bef, parent=par, prev=prev)

Insert a new node carrying data such that the next sibling of this new node
will be `bef`. The parent node and the previous node to `bef` are required
to update all links in the data structure. If `bef` is the first child of `par`,
the previous node `prev` should be pasesed as `0`. Similarly, if the new node
should be inserted as the last child, `bef` should be passed as `0`. In the
special case of a parent node without any existing children, both `bef` and
`prev` should be set to `0`.

It may seem redundant to pass also `prev`, but this is a necessity of the single
linked list implementation of `PointerBasedTree`.
"""
# function ClusterTrees.insert!(tree::PointerBasedTree, data; parent, next, prev)
#     push!(tree.nodes, Node(data, 0, next, parent, 0))
#     @assert !(parent < 1)
#
#     fs = firstchild(tree, parent)
#     if fs < 1 || fs == next
#         setfirstchild!(tree, parent, length(tree.nodes))
#     end
#     if !(prev < 1)
#         setnextsibling!(tree, prev, length(tree.nodes))
#     end
#     return length(tree.nodes)
# end


function Base.insert!(chd_itr::ChildIterator{<:APBTree}, item, state)
    prev, next = state
    parent = chd_itr.node

    tree = chd_itr.tree
    push!(tree.nodes, Node(data, 0, next, parent, 0))
    this = lastindex(tree.nodes)
    if prev < 1
        setfirstchild!(tree, parent, this)
    else
        setnextsibling!(tree, prev, this)
    end
    return this
end

end
