# Introduction

The API is built on top of a number of simple concepts.

- It is assumed that a tree is not identified with its root. If this happens to be the case in your concrete data structure, implement [`ClusterTrees.root`](@ref) as a no-op.
- There are a number of different iterators that a tree can produce. The simplest kind of iterators are *nodes*. Nodes can be assumed to be small and of fixed type. As a result it is cheap and efficient to store nodes in external containers for additional bookkeeping and traversal. `root` and `children` produce nodes.

The core of the tree API consists of the following functions:

```@docs
ClusterTrees.root
ClusterTrees.children
ClusterTrees.data
```

Based on this simple API, the following algorithms are enabled:

```@docs
ClusterTrees.depthfirst
ClusterTrees.print_tree
ClusterTrees.DepthFirstIterator
```

To update the tree (this includes both modifying already attached data and inserting new data):

```@docs
ClusterTrees.update!
```



## Pointer based trees

Tree implementations based on pointers (or indices into Vector-backed memory buffers) are very popular and allow for the efficient implementation of most common traversal and mutation patterns. These trees support an enriched API. We only consider trees with nodes that link back to their parents.

```@docs
nextsibling
parent
firstchild
```
