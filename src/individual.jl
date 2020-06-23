export NEATIndiv

mutable struct NEATIndiv <: Cambrian.Individual
    genes::Array{Gene}
    fitness::Array{Float64}
    neuron_pos::Array{Float64}
    network::Network
end

function NEATIndiv(cfg::Dict)
    n_in = cfg["n_in"]
    n_out = cfg["n_out"]
    neuron_pos::Array{Float64}=[]

    # Neuron positions: Input and output
    neuron_pos = -n_in:n_out

    # Add genes
    genes::Array{Gene}=[]
    if cfg["start_fully_connected"]!=0
        for i in 1:n_in
            for j in 1:n_out
                inno = i * n_out + j
                push!(genes, Gene(-1.0 * i, 1.0 * j, inno))
            end
        end
    end
    cfg["innovation_max"] = n_in * n_out

    sort!(neuron_pos)

    fitness = -Inf .* ones(cfg["d_fitness"])

    network = Network(n_in, n_out, Dict())

    NEATIndiv(genes, fitness, neuron_pos, network)
end

function NEATIndiv(ind::NEATIndiv)
    ind2 = deepcopy(ind)
    ind2.fitness .= -Inf
    ind2
end
