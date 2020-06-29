export Layer, Connection, GridNetwork, height_of
## Neuron Layer

mutable struct Layer
    size::Int64
    values::Array{Float64}
    biases::Array{Float64}
    activ_func::Function
    depth::Float64
end

function Layer(size::Int64, cfg::Dict)
    values = zeros(size)
    biases = rand(size)
    Layer(size, values, biases, rand(cfg["activation_functions"]))
end

## Connection between layers

mutable struct Connection
    layer_from::Layer
    layer_to::Layer
    weigths::Array{Float64}
end

function Connection(layer_from::Layer, layer_to::Layer)
    values = rand((layer_to.size, layer_from.size))
    Connection(layer_from, layer_to, values)
end

function height_of(i::Int64, layer_size::Int64)
    if layer_size <= 1
        0
    else
        -1 + (i-1) * 2 / (layer_size - 1)
    end
end

function Connection(generator_func::Function, layer_from::Layer, layer_to::Layer)
    w = zeros((layer_to.size, layer_from.size))
    for i in 1:layer_to.size
        for j in 1:layer_from.size
            x1 = height_of(j, layer_from.size)
            y1 = layer_from.depth
            x2 = height_of(j, layer_to.size)
            y2 = layer_to.depth
            w[i, j] = generator_func([x1, y1, x2, y2])
        end
    end
    Connection(layer_from, layer_to, w)
end

function Connection(values::Array{Float}, layer_from::Layer, layer_to::Layer)
    w = reshape(values, (layer_to.size, layer_from.size))
    Connection(layer_from, layer_to, w)
end


## Full Network

mutable struct GridNetwork
    layers::Array{Layer}
    connections::Dict
end

function GridNetwork(layers_size::Array{Int64})
    l::Array{Layer} = []
    for size in layers_size
        push!(l, Layer(size))
end

function process(net::GridNetwork, last_features::Array{Float64})
    body
end
