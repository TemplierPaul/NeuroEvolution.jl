export Layer, Connection, GridNetwork, HyperNEATIndividual, height_of
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
    layers_size = [cfg["n_in"]]
    append!(layers_size, cfg["hn_hidden_layers"])
    push!(layers_size, cfg["n_out"])
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

mutable struct HyperNEATIndividual <: NEATIndiv
    genes::Dict
    fitness::Array{Float64}
    neuron_pos::Array{Float64}
    network::Network
    activ_functions::Dict
    hn_net::GridNetwork
end

function HyperNEATIndividual(cfg::Dict)
    n_in = 4
    n_out = 1
    neuron_pos::Array{Float64}=[]

    # Neuron positions: Input and output
    neuron_pos = -n_in:n_out

    # Neurons activation functions
    activ_functions = Dict()
    for i in neuron_pos
        activ_functions[i]=rand(cfg["activation_functions"])
    end

    # Add genes
    genes=Dict()
    if cfg["start_fully_connected"]
        for i in 1:n_in
            for j in 1:n_out
                inno = i * n_out + j
                genes[inno] = Gene(-1.0 * i, 1.0 * j, inno)
            end
        end
        cfg["innovation_max"] = maximum([cfg["innovation_max"], n_in * n_out])
    end

    sort!(neuron_pos)

    fitness = -Inf .* ones(cfg["d_fitness"])

    neat_network = Network(n_in, n_out, Dict())
    grid_net = GridNetwork(cfg)

    HyperNEATIndividual(genes, fitness, neuron_pos, neat_network, activ_functions, grid_net)
end

function HyperNEATIndividual(cfg::Dict, s::String)
	NEATIndiv(cfg, s)
end

## Build / process

function build!(indiv::HyperNEATIndividual)
    reset(indiv.network)
    build_NEAT!(indiv)
    # Network generator function
    generator::Function = x -> process_NEAT(indiv, x)
    set_weights!(indiv.hn_net, generator)
end

function process(indiv::HyperNEATIndividual, last_features::Array{Float64})
    process(indiv.hn_net, last_features)
end
