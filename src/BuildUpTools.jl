module BuildUpTools
using Base
using AbstractTrees

include("buildup.jl")
export BuildUp, NoBuildUp, OptionalBuildUp
export @addnode, @addbranch, addnode, sumall!, headnode, nodetype, innertree

include("inertia.jl")
export InertiaBuildUp, InertialElement

end
