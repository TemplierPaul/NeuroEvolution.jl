module JuNEAT

using Cambrian
using YAML
using JSON
using Random

include("utils.jl")
include("config.jl")

include("gene.jl")
include("NEAT_network.jl")
include("individual.jl")
include("process.jl")

include("loader.jl")

include("mutation.jl")
include("crossover.jl")

include("species.jl")
include("populate.jl")

include("HyperNEAT.jl")

include("evolution.jl")
end # module
