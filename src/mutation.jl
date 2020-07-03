export mutate_weight, mutate_connect, mutate_neuron, mutate_enabled, mutate

"Mutate the weight of genes"
function mutate_weight(ind::NEATIndiv, cfg::Dict)
    #TODO Add mutation power
    # https://github.com/FernandoTorres/NEAT/blob/master/src/genome.cpp
    ind_mut = NEATIndiv(ind)
    for g in values(ind_mut.genes)
        g.weight = g.weight + randn()*cfg["weight_factor"]
    end
    ind_mut.fitness.= -Inf
    ind_mut
end

function indexof(a::Array{Float64}, f::Float64)
    findall(x->x==f, a)[1]
end

"Add a connection between 2 random neurons"
function mutate_connect(ind::NEATIndiv, cfg::Dict)
    sort!(ind.neuron_pos)

    ind_mut = NEATIndiv(ind)
    nb_neur = length(ind_mut.neuron_pos)
    # println(nb_neur, " ", ind.neuron_pos)

    if cfg["hyperNEAT"] # HyperNEAT
        n_in = 4
        n_out = 1
    else # NEAT
        n_in = cfg["n_in"]
        n_out = cfg["n_out"]
    end

    # Valid neuron pairs
    valid = trues(nb_neur, nb_neur)

    # Remove existing ones
    for g in values(ind.genes)
        i_origin = indexof(ind.neuron_pos, g.origin)
        i_dest = indexof(ind.neuron_pos, g.destination)
        valid[i_origin, i_dest]=false
    end


    for orig in 1:nb_neur
        # Remove links to self
        valid[orig, orig]=false

        orig_pos = ind.neuron_pos[orig]

        for dest in 1:nb_neur
            dest_pos = ind.neuron_pos[dest]

            # Remove links towards input neurons and bias neuron
            if dest_pos <= 0
                valid[orig, dest]=false
            end

            # Remove links between output neurons (would not support adding a neuron)
            if orig_pos >= 1 && dest_pos >= 1
                valid[orig, dest]=false
            end

            # Remove recurrence if needed
            if !cfg["allow_recurrence"] && orig_pos > dest_pos
                valid[orig, dest]=false
            end
        end
    end

    ind_mut.fitness.= -Inf
    ind_mut.network = Network(n_in, n_out, Dict()) # Reset network

    # Filter invalid ones
    conns = findall(valid)
    if length(conns) > 0
        shuffle!(conns) # Pick random
        cfg["innovation_max"] += 1

        i = ind.neuron_pos[conns[1][1]]
        j = ind.neuron_pos[conns[1][2]]
        if j <= 0 # Catching error where destination is an input
            return ind_mut # Refuse mutation
        end

        g = Gene(i, j, cfg["innovation_max"])

        ind_mut.genes[cfg["innovation_max"]]=g
    end
    ind_mut
end

"Remove a random connection"
function mutate_disconnect(ind::NEATIndiv, cfg::Dict)
    ind_mut = NEATIndiv(ind)
    if length(ind_mut.genes)<=1 # Always keep 1 gene
        return ind_mut
    end
    k = rand(collect(keys(ind_mut.genes))) # pick a random gene
    pop!(ind_mut.genes, k) # remove it
    if cfg["hyperNEAT"] # HyperNEAT
        n_in = 4
        n_out = 1
    else # NEAT
        n_in = cfg["n_in"]
        n_out = cfg["n_out"]
    end
    ind_mut.network = Network(n_in, n_out, Dict()) # Reset network
    ind_mut
end

"Split a connection into 2 connections with a new neuron"
function mutate_neuron(ind::NEATIndiv, cfg::Dict)
    ind_mut = NEATIndiv(ind)

    if length(ind.genes)==0
        return ind_mut
    end

    # Connection to split
    g = rand(collect(values(ind_mut.genes)))
    g.enabled = false

    # Create neuron between origin and destination, in [0; 1]
    n = random_position(g.origin, g.destination)
    push!(ind_mut.neuron_pos, n)
    sort!(ind_mut.neuron_pos)
    ind_mut.activ_functions[n] = rand(cfg["activation_functions"])

    # Create connections
    i = cfg["innovation_max"]
    ind_mut.genes[i+1] = Gene(g.origin, n, i+1)
    ind_mut.genes[i+2] = Gene(n, g.destination, i+2)
    cfg["innovation_max"] +=2
    ind_mut.fitness.= -Inf
    ind_mut
end

"Switch enabled"
function mutate_enabled(ind::NEATIndiv, cfg::Dict)
    ind_mut = NEATIndiv(ind)
    g = rand(collect(values(ind_mut.genes)))
    g.enabled = !g.enabled
    ind_mut
end

function mutate(ind::NEATIndiv, cfg::Dict)
    # println("mutation")
    if rand() < cfg["p_mutate_add_neuron"]
        c =  mutate_neuron(ind, cfg)
    elseif rand() < cfg["p_mutate_add_connection"]
        c = mutate_connect(ind, cfg)
    elseif rand() < cfg["p_mutate_remove_connection"]
        c = mutate_disconnect(ind, cfg)
    elseif rand() < cfg["p_mutate_weights"]
        c = mutate_weight(ind, cfg)
    elseif rand() < cfg["p_mutate_enabled"]
        c = mutate_enabled(ind, cfg)
    else
        # return clone if no mutation occurs
        c = NEATIndiv(ind)
    end
    build!(c)
    c
end
