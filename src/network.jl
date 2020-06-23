export Neuron, Network

mutable struct Neuron
    position::Float64
    activ_func::Function
    output::Float64
    connections::Array{Gene}
end

struct Network
    n_in::Int64
    n_out::Int64
    neurons::Dict
end

function Neuron(neur::Neuron)
    deepcopy(neur)
end

function Network(net::Network)
    deepcopy(net)
end
