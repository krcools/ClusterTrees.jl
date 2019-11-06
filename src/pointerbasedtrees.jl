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
ClusterTrees.parent(tree::PointerBasedTree, node_idx) = getnode(tree, node_idx).parent
firstchild(tree::PointerBasedTree, node_idx) = getnode(tree, node_idx).first_child

start(itr::ChildIterator{<:APBTree}) = (0, firstchild(itr.tree, itr.node))
function done(itr::ChildIterator{<:APBTree}, state)
    prev, this = state
    this < 1 && return true
    sibling_par = ClusterTrees.parent(itr.tree, this)
    sibling_par != itr.node && return true
    return false
end

function next(itr::ChildIterator{<:APBTree}, state)
    prev, this = state
    nxt = nextsibling(itr.tree, this)
    return (this, (this, nxt))
end


Base.iterate(itr::ChildIterator{<:APBTree}, st = start(itr)) = done(itr,st) ? nothing : next(itr,st)

# Base.IteratorSize(cv::ChildIterator) = Base.SizeUnknown()

ClusterTrees.root(tree::PointerBasedTree) = tree.root
ClusterTrees.children(tree::APBTree, node=ClusterTrees.root(tree)) = ChildIterator(tree, node)
ClusterTrees.haschildren(tree::APBTree, node) = (firstchild(tree,node) >= 1)
ClusterTrees.data(tree::PointerBasedTree, node=ClusterTrees.root(tree)) = data(getnode(tree, node))

# """
#     insert!(tree, parent, data)
#
# Insert a node carrying `data` as the first child of `parent`
# """
# function ClusterTrees.insert!(tree::PointerBasedTree, parent_idx, data)
#     next = firstchild(tree, parent_idx)
#     ClusterTrees.insert!(tree, data, parent=parent_idx, next=next, prev=0)
# end


setfirstchild!(node::Node, child) = Node(node.data, node.num_children, node.next_sibling, node.parent, child)
setfirstchild!(tree::PointerBasedTree, node, child) = tree.nodes[node] = setfirstchild!(getnode(tree, node), child)

setnextsibling!(node::Node, next) = Node(node.data, node.num_children, next, node.parent, node.first_child)
setnextsibling!(tree::PointerBasedTree, node, next) = tree.nodes[node] = setnextsibling!(getnode(tree, node), next)

"""
    insert!(child_iterator, item, position)

Insert item at 'position' in 'child_iterator'. Here, 'position' is a state generated
using 'start/next/done' acting on 'child_iterator', which in turn is created by
'children(tree, node)'.
"""
function Base.insert!(chd_itr::ChildIterator{<:APBTree}, item, state)
    prev, next = state
    parent = chd_itr.node

    tree = chd_itr.tree
    push!(tree.nodes, Node(item, 0, next, parent, 0))
    this = lastindex(tree.nodes)
    if prev < 1
        setfirstchild!(tree, parent, this)
    else
        setnextsibling!(tree, prev, this)
    end
    return this
end

end
