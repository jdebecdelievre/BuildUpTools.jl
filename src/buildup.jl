"""
Simple tree structure that allows to build drag and mass buildups easily.
Main constructor:
    tree = BuildUp(name, value)
    OR a shortcut 
    tree = BuildUp(name, value)
Supports:
    - get child: child = tree[name]
    - add node from name, value: tree[name] = value
    - macros for efficient node or branch addition
        - @addnode tree node1 node2 node3...
        - @addbranch tree node subnode1 subnode2...
    - compute all node values from leaf information: sumall!. 
    - get headnode (cuts off children to avoid recomputing sums with all leaves): headnode(tree)
    - get single branch : branch(tree, new_head_node_name)
    - pretty printing print_tree
The node's value field can have any type. If using custom type, make sure to define sum() and + operations. 
See InertiaBuildUp for an example of custom value type.
"""

# Main node type:
mutable struct BuildUp{T}
    name::Symbol
    value::T
    children::Dict{Symbol,BuildUp{T}}
    @inline function BuildUp(name::Symbol, value::T) where T
        return new{T}(name, value, Dict{Symbol,BuildUp{T}}())
    end
end

const NoBuildUp = BuildUp(:NoBuildUp, nothing)
Base.getindex(tree::BuildUp{T} where T, c::Symbol) = tree.children[c]
Base.setindex!(tree::BuildUp{T}, child::BuildUp{T}, name::Symbol) where T = setindex!(tree.children, child, name)
branch(tree::BuildUp, c::Symbol) = tree.children[c]
headnode(tree::BuildUp) = BuildUp(tree.name, tree.value) # cuts off depth
addnode(tree::BuildUp{T}, name::Symbol, value::T=tree.value) where T = (tree.children[name]=BuildUp(name,value))

# Pretty printing. AbstractTrees only used for printing, dependency could be removed if necessary
AbstractTrees.printnode(io::IO, node::BuildUp) = print(io, "$(node.name): $(node.value)")
AbstractTrees.children(itree::BuildUp) = itree.children
AbstractTrees.nodetype(::BuildUp) = BuildUp
Base.show(io::IO, tree::BuildUp) = print_tree(io, tree, 3) # using depth of 3

# Summation routine
function sumall!(tree::BuildUp)
    if ~isempty(tree.children)
        tree.value = sum(sumall!(node) for node=values(tree.children))
    end
    return tree.value
end

# Duplicate all methods to make sure logging is ignored if necessary
Base.getindex(tn::BuildUp{<:Nothing}, ::Symbol) = nothing
Base.setindex!(tn::BuildUp{<:Nothing}, ::Any, ::Symbol) = tn
addnode(tn::BuildUp{<:Nothing}, ::Symbol, ::Any) = tn
addnode(tn::BuildUp{T}, ::Symbol, ::T) where T<:Nothing = tn
branch(::BuildUp{<:Nothing}, ::Symbol) = nothing
headnode(tn::BuildUp{<:Nothing}) = tn
sumall!(tn::BuildUp{<:Nothing}) = tn

## Macros for convenience
"""
```julia_skip
vnode = @addnode tree v1 v2 v3
```
Add one or more children to the tree whose names are v1,v2,..., and value are the values of v1,v2,....
Return newly created node, or nothing if tree was of type Nothing.
"""
macro addnode(tree, V...)
    T = Expr(:block, Tuple(:(addnode($tree, $(Expr(:quote, v)), $v)) for v=V)...)
    esc(T)
end

"""
```julia_skip
V = @addbranch tree V(v1,v2,v3)
```
Add a child to the tree node Node whose name is V, and children are v1, v2, v3. 
Also creates nodes for v1,v2,v3 with respective names and values. 
Returns root node of subtree, or nothing if tree was of type Nothing.
"""
macro addbranch(tree, V)
    esc(quote
        vr = addnode($tree, $(V.args)[1], ($tree).value)
        @addnode vr $(V.args[2:end]...)
    end)
end
