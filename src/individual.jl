export NEATIndiv

mutable struct NEATIndiv <: Cambrian.Individual
    genes::Array{Gene}
    fitness::Array{Float64}
    neuron_pos::Array{Float64}
end

function NEATIndiv(cfg::Dict)
    n_in = cfg["n_in"]
    n_out = cfg["n_out"]
    neuron_pos::Array{Float64}=[]

    # Input neurons
    for i in 1:n_in
        push!(neuron_pos, -i)
    end
    # Output neurons
    for i in 1:n_out
        push!(neuron_pos, 1+i)
    end

    # Add genes
    genes::Array{Gene}=[]
    if cfg["start_fully_connected"]!=0
        for i in 1:n_in
            for j in 1:n_out
                inno = i * n_out + j
                push!(genes, Gene(-1.0 * i, j+1.0, inno))
            end
        end
    end
    cfg["innovation_max"] = n_in * n_out

    sort!(genes, by= g -> g.inno_nb, rev=false)
    sort!(neuron_pos)

    fitness = -Inf .* ones(cfg["d_fitness"])

    NEATIndiv(genes, fitness, neuron_pos)
end

function NEATIndiv(ind::NEATIndiv)
    ind2 = deepcopy(ind)
    ind2.fitness .= -Inf
    ind2
end
