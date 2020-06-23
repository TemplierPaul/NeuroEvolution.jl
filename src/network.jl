export Neuron, Network

mutable struct Neuron
    position::Float64
    activ_func::Function
    input::Float64
    output::Float64
end

struct Network
    a::Int
end
