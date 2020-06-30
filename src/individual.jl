export NEATIndiv, distance

mutable struct NEATIndiv <: Cambrian.Individual
    genes::Dict
    fitness::Array{Float64}
    neuron_pos::Array{Float64}
    network::Network
    activ_functions::Dict
end

function NEATIndiv(cfg::Dict)
    n_in = cfg["n_in"]
    n_out = cfg["n_out"]
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

    network = Network(n_in, n_out, Dict())

    NEATIndiv(genes, fitness, neuron_pos, network, activ_functions)
end

function NEATIndiv(ind::NEATIndiv)
    deepcopy(ind)
end

function distance(i1::NEATIndiv, i2::NEATIndiv, cfg::Dict)
    # N = maximum([length(g1), length(g2)])   # Paper version
    N = 1 # Implementation version

    # Check for empty genomes
    if length(i1.genes)==0
        return cfg["excess_coef"] * length(i2.genes) / N
    end
    if length(i2.genes)==0
        return cfg["excess_coef"] * length(i1.genes) / N
    end

    # Gene innovation numbers in each individual
    g1 = keys(i1.genes)
    g2 = keys(i2.genes)


    excess = 0.
    disjoint = 0.
    weight_diffs = []
    for i in 1:cfg["innovation_max"]
        if i in g1
            if i in g2
                # In both
                d = abs(i1.genes[i].weight - i2.genes[i].weight)
                push!(weight_diffs, d)
            else # Only in g1
                if i > maximum(g2)
                    excess += 1
                else
                    disjoint += 1
                end
            end
        else
            if i in g2 # Only in g2
                if i > maximum(g1)
                    excess += 1
                else
                    disjoint += 1
                end
            end
        end
    end

    dist = cfg["excess_coef"] * excess / N
    dist += cfg["disjoint_coef"] * disjoint / N

    if length(weight_diffs) > 0
        dist += cfg["weight_diff_coef"] * sum(weight_diffs) / length(weight_diffs)
    end

    dist
end

function Base.show(io::IO, ::MIME"text/plain", indiv::NEATIndiv)
    for fname in fieldnames(indiv)
        println(io, getfield(indiv, fname))
    end
end
