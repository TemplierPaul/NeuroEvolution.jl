export Neuron, process

mutable struct Neuron
    position::Float64
    activ_func::Function
    input::Float64
    output::Float64
end

function process(indiv::NEATIndiv, cfg::Dict)
    body
end
