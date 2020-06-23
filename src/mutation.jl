export mutate_weight, mutate_connect, mutate_neuron, mutate_enable, mutate

function mutate_weight(ind::NEATIndiv, cfg::Dict)
    ind_mut = NEATIndiv(ind)
    for g in ind_mut.genes
        if rand() < cfg["p_mut_weights"]
            g.weight = g.weight + randn()*cfg["weight_factor"]
        end
    end
    ind_mut
end

function indexof(a::Array{Float64}, f::Float64)
    findall(x->x==f, a)[1]
end

function mutate_connect(ind::NEATIndiv, cfg::Dict)
    sort!(ind.neuron_pos)

    ind_mut = NEATIndiv(ind)
    nb_neur = length(ind_mut.neuron_pos)

    n_in = cfg["n_in"]
    n_out = cfg["n_out"]

    # Valid neuron pairs
    valid = trues(nb_neur, nb_neur)

    # Remove existing ones
    for g in ind.genes
        i_origin = indexof(ind.neuron_pos, g.origin)
        i_dest = indexof(ind.neuron_pos, g.destination)
        valid[i_origin, i_dest]=false
    end

    # Filter invalid ones
    conns = findall(valid)
    if length(conns) > 0
        shuffle!(conns) # Pick random
        cfg["innovation_max"] += 1

        i = ind.neuron_pos[conns[1][1]]
        j = ind.neuron_pos[conns[1][2]]

        g = Gene(i, j, cfg["innovation_max"])

        push!(ind_mut.genes, g)
        ind_mut.network = Network(n_in, n_out, Dict()) # Reset network
    end
    ind_mut
end

function mutate_neuron(ind::NEATIndiv, cfg::Dict)
    ind
end

function mutate_enable(ind::NEATIndiv, cfg::Dict)
    ind
end

function mutate(ind::NEATIndiv, cfg::Dict)
    ind
end
