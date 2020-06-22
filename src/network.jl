mutable struct Neuron
    position::Float64
    activ_func::Function
    input::Float64
    output::Float64
end

mutable struct Network
    neurons::Array{Neuron}
end

function Network(ind:NEATIndiv)
    body
end
