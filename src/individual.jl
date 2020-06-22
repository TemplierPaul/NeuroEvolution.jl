mutable struct NEATIndiv <: Cambrian.Individual
    genes::Array{Gene}
    fitness::Array{Float64}
    neurons::Array{Float64}
end

function NEATIndiv(cfg:Dict)
    n_in = cfg["n_in"]
    n_out = cfg["n_out"]
    neurons::Array{Float64}=[]

    # Input neurons
    for i in 1:n_in
        push!(neurons, Neuron(-1.0*i, activation, 0, 0))
    end
    # Output neurons
    for i in 1:n_out
        push!(neurons, Neuron(-1.0*i, activation, 0, 0))
    end

    # Add genes
    genes::Array{Gene}=[]
    if cfg["start_fully_connected"]!=0
        for i in 1:n_in
            for j in 1:n_out
                inno = i * n_out + j
                push!(genes, Gene(i, j, inno))
            end
        end
    end
    cfg["innovation_max"] = n_in * n_out

    fitness = -Inf .* ones(cfg["d_fitness"])

    NEATIndiv(genes, fitness, neurons)
end

function NEATIndinv(ind::NEATIndiv)
    ind2 = deepcopy(ind)
    ind2.fitness .= -Inf
    ind2
end
