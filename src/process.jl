export build!, process

"Create the network from the individual"
function build!(indiv::NEATIndiv)
    n_in = Integer(-1 * minimum(indiv.neuron_pos))
    n_out = Integer(maximum(indiv.neuron_pos))
    net = Network(n_in, n_out, Dict())

    # Create neurons
    for p in indiv.neuron_pos
        func = indiv.activ_functions[p]
        net.neurons[float(p)] = Neuron(float(p), func, 0., [])
    end
    # Add constant neuron for bias at 0
    net.neurons[0] = Neuron(0, sigmoid, 0., [])

    # For each neuron, make a list of connections towards it
    for g in values(indiv.genes)
        if g.enabled
            push!(net.neurons[g.destination].connections, g)
        end
    end
    indiv.network = net
end

"Set all outputs to 0"
function reset(net::Network)
    for n in values(net.neurons)
        n.output = 0.
    end
end

"Compute the output value of a neuron"
function compute!(n::Neuron, neur_dict::Dict)
    sum::Float64 = 0.
    for c in n.connections
        origin_neuron = neur_dict[c.origin]
        sum += origin_neuron.output
    end
    n.output = n.activ_func(sum)
end

"Process one input"
function process(indiv::NEATIndiv, last_features::Array{Float64})
    build!(indiv)
    reset(indiv.network)

    for p in indiv.neuron_pos
        if p < 0 # Input neurons
            indiv.network.neurons[p].output = last_features[Int(-p)]
        elseif p == 0 # Bias neuron
            indiv.network.neurons[p].output = 1
        else # Hidden and output neurons
            compute!(indiv.network.neurons[p], indiv.network.neurons)
        end
    end

    out::Array{Float64} = []
    for i in 1:indiv.network.n_out
        push!(out, indiv.network.neurons[1.0*i].output)
    end
    out
end

"Process an array of inputs"
function process(indiv::NEATIndiv, last_features::Array{Array{Float64}})
    out::Array=[]
    for x in last_features
        push!(out, process(indiv, x))
    end
    out
end

""
function NEAT_fitness(indiv::NEATIndiv, fitness::Function, fitness_args...)
    process_indiv = x -> process(indiv, x)
    fitness(process_indiv, fitness_args...)
end
