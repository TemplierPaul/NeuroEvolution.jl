export Layer, Connection, GridNetwork, height_of
## Neuron Layer

mutable struct Layer
    size::Int64
    values::Array{Float64}
    biases::Array{Float64}
    activ_func::Function
    depth::Float64
    connections_towards::Array
end

function Layer(size::Int64, depth::Float64, activ_func::Function)
    values = zeros(size)
    biases = zeros(size)
    Layer(size, values, biases, activ_func, depth, [])
end

## Connection between layers

mutable struct Connection
    layer_from::Layer
    layer_to::Layer
    weights::Array{Float64}
end

function Connection(layer_from::Layer, layer_to::Layer)
    values = rand(Float64, (layer_from.size, layer_to.size))
    c = Connection(layer_from, layer_to, values)
    push!(layer_to.connections_towards, c)
    c
end

function normalize(i::Int64, layer_size::Int64)
    if layer_size <= 1
        0
    else
        -1 + (i-1) * 2 / (layer_size - 1)
    end
end

function Connection(generator_func::Function, layer_from::Layer, layer_to::Layer)
    w = zeros((layer_from.size, layer_to.size))
    for i in 1:layer_from.size
        for j in 1:layer_to.size
            x1 = normalize(j, layer_from.size)
            y1 = layer_from.depth
            x2 = normalize(j, layer_to.size)
            y2 = layer_to.depth
            w[i, j] = generator_func([x1, y1, x2, y2])
        end
    end
    Connection(layer_from, layer_to, w)
end

function Connection(values::Array{Float64}, layer_from::Layer, layer_to::Layer)
    w = reshape(values, (layer_from.size, layer_to.size))
    c = Connection(layer_from, layer_to, w)
    push!(layer_to.connections_towards, c)
    c
end

function set_weights!(conn::Connection, generator_func::Function)
    w = zeros((conn.layer_from.size, conn.layer_to.size))
    for i in 1:conn.layer_from.size
        for j in 1:conn.layer_to.size
            x1 = normalize(j, conn.layer_from.size)
            y1 = conn.layer_from.depth
            x2 = normalize(j, conn.layer_to.size)
            y2 = conn.layer_to.depth
            w[i, j] = generator_func([x1, y1, x2, y2])[1]
        end
    end
    conn.weights = w
end

## Full Network

mutable struct GridNetwork
    layers::Array{Layer}
    connections::Array{Connection}
end

function GridNetwork(cfg::Dict)
    layers::Array{Layer} = []
    layers_size = cfg["hn_layers"]
    for i in 1:length(layers_size)
        depth = normalize(i, length(layers_size))
        push!(layers, Layer(layers_size[i], depth, cfg["hn_activ_func"]))
    end

    connections::Array{Connection} = []
    for j in 2:length(layers) # Layer_to
        if cfg["hn_link_all_layers"] # Connect from all previous layers
            for i in 1:j-1 # Layer_from
                push!(connections, Connection(layers[i], layers[j]))
            end
        else # Only connect from previous layer
            push!(connections, Connection(layers[i], layers[i-1]))
        end
    end
    # println("Network ", getfield.(layers, :size))
    GridNetwork(layers, connections)
end

function set_weights!(net::GridNetwork, generator_func::Function)
    for c in net.connections
        set_weights!(c, generator_func)
    end
end

## Process network

function process(net::GridNetwork, last_features::Array{Float64})
    # Set values of the first
    net.layers[1].values = reshape(last_features, (1, net.layers[1].size))

    for l in net.layers[2:length(net.layers)]
        l.values = zeros((1, l.size)) # Reset sum
        for c in l.connections_towards
            v = reshape(c.layer_from.values, (1, c.layer_from.size))
            l.values += v * c.weights
        end
        l.values = l.activ_func.(l.values)
    end
    sort!(net.connections, by=x-> x.layer_to.depth)
    for c in net.connections

    end
    net.layers[end].values
end

"Process an array of inputs"
function process(net::GridNetwork, last_features::Array{Array{Float64}})
    out::Array=[]
    for x in last_features
        push!(out, process(net, x))
    end
    out
end

## HyperNEAT fitness transformator

"Creates a wrapper for the fitness, so the HyperNEAT_fitness can be used transparently in NEAT"
function HyperNEAT_fitness(indiv::NEATIndiv, fitness::Function, fitness_args...; cfg::Dict)
    net = GridNetwork(cfg)
    # Network generator function
    generator::Function = x -> process(indiv, x)
    set_weights!(net, generator)
    # Evaluation of the produced network
    process_indiv = x -> process(net, x)
    fitness(process_indiv, fitness_args...)
end
