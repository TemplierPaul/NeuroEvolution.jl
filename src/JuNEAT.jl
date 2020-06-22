module JuNEAT

using Cambrian
using YAML
using JSON
using Random

include("config.jl")
include("utils.jl")

include("individual.jl")
include("gene.jl")
include("network.jl")

include("mutation.jl")
include("crossover.jl")

end # module
