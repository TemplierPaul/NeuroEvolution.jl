mutable struct NEATIndiv <: Cambrian.Individual
    neurons::Array{Float64}
    genes::Array{Gene}
    fitness::Array{Float64}
    network::Network
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



    if cfg["start_fully_connected"]!=0
        for i in 1:n_in
            for j in 1:n_out

            end
        end
    end

    fitness = -Inf .* ones(cfg["d_fitness"])
    NEATIndiv([], cfg.)
end

function NEATIndinv(ind::NEATIndiv)
    ind2 = deepcopy(ind)
    ind2.fitness .= -Inf
    ind2
end
