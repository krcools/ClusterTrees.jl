var documenterSearchIndex = {"docs":
[{"location":"#Introduction-1","page":"Introduction","title":"Introduction","text":"","category":"section"},{"location":"#","page":"Introduction","title":"Introduction","text":"The API is built on top of a number of simple concepts.","category":"page"},{"location":"#","page":"Introduction","title":"Introduction","text":"It is assumed that a tree is not identified with its root. If this happens to be the case in your concrete data structure, implement ClusterTrees.root as a no-op.\nThere are a number of different iterators that a tree can produce. The simplest kind of iterators are nodes. Nodes can be assumed to be small and of fixed type. As a result it is cheap and efficient to store nodes in external containers for additional bookkeeping and traversal. root and children produce nodes.","category":"page"},{"location":"#","page":"Introduction","title":"Introduction","text":"The core of the tree API consists of the following functions:","category":"page"},{"location":"#","page":"Introduction","title":"Introduction","text":"ClusterTrees.root\nClusterTrees.children\nClusterTrees.data","category":"page"},{"location":"#ClusterTrees.root","page":"Introduction","title":"ClusterTrees.root","text":"root(tree)\n\nReturn a proxy for the root of the tree.\n\n\n\n\n\n","category":"function"},{"location":"#ClusterTrees.children","page":"Introduction","title":"ClusterTrees.children","text":"The expression children(tree,node) returns an iterator that will produce a sequence of nodes. These values do not have a lot of meaning by themselves, but can be used in conjunction with the tree object. E.g:\n\ndata(tree, node_itr)\nchildren(tree, node_itr)\n\nIn fact, the node iterators should be regarded as lightweight proxies for the underlying node and their attached data payload. The node objects themselves are of limited use for the client programmer as they are an implementation detail of the specific tree being used.\n\n\n\n\n\n","category":"function"},{"location":"#ClusterTrees.data","page":"Introduction","title":"ClusterTrees.data","text":"data(tree, node)\n\nRetrieve the data aka payload associated with the given node.\n\n\n\n\n\n","category":"function"},{"location":"#","page":"Introduction","title":"Introduction","text":"Based on this simple API, the following algorithms are enabled:","category":"page"},{"location":"#","page":"Introduction","title":"Introduction","text":"ClusterTrees.depthfirst\nClusterTrees.print_tree\nClusterTrees.DepthFirstIterator","category":"page"},{"location":"#ClusterTrees.depthfirst","page":"Introduction","title":"ClusterTrees.depthfirst","text":"Traverse the tree depth first, executing the function f(tree, node, level) at every node. If f returns false, recursion is halted and the next node on the current level is visited.\n\n\n\n\n\n","category":"function"},{"location":"#ClusterTrees.DepthFirstIterator","page":"Introduction","title":"ClusterTrees.DepthFirstIterator","text":"DepthFirstIterator(tree, node)\n\nCreates an iterable that when traversed visits the nodes of the subtree (tree, node) in depthfirst order. Children of a node are visited before that node itself.\n\n\n\n\n\n","category":"type"},{"location":"#","page":"Introduction","title":"Introduction","text":"To update the tree (this includes both modifying already attached data and inserting new data):","category":"page"},{"location":"#","page":"Introduction","title":"Introduction","text":"ClusterTrees.update!","category":"page"},{"location":"#ClusterTrees.update!","page":"Introduction","title":"ClusterTrees.update!","text":"update!(f, tree, state, data, target)\n\nAlgorithm to update or add data to the tree. router! and updater! are user supplied functions:\n\nroute!(tree, state, target)\n\nReturns the next candidate node until the node for insertion is reaches. Note that this function potentially created new nodes. Arrival at the destination is indicated by returning the same node that was passed as the second argument.\n\nf(tree, node, data)\n\nUpdate the destination node node. Typically, data is added in some sense to the data residing at the desitination node.\n\n\n\n\n\n","category":"function"},{"location":"#Pointer-based-trees-1","page":"Introduction","title":"Pointer based trees","text":"","category":"section"}]
}