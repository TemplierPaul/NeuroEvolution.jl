export crossover

function crossover(parent1::NEATIndiv, parent2::NEATIndiv, cfg::Dict)
    if cfg["hyperNEAT"] # HyperNEAT
        n_in = 4
        n_out = 1
    else # NEAT
        n_in = cfg["n_in"]
        n_out = cfg["n_out"]
    end
    # get p1 parent with best fitness to keep its genes
    p1, p2 = sort([parent1, parent2], by=x -> x.fitness[1], rev=true)
    child = NEATIndiv(p1)

    # Child connections
    child_genes=Dict()
    neuron_pos::Array{Float64}=[]
    for i in keys(merge(p1.genes, p2.genes))
        g = nothing
        if i in keys(p1.genes)
            # Both parents have the gene: pick random
            if  i in keys(p1.genes)
                if rand()>0.5
                    g = Gene(p1.genes[i])
                else
                    g = Gene(p1.genes[i])
                end
            # Only parent 1 has it: add it
            else
                g = Gene(p1_genes[i])
            end
        end

        # Add the connection to the child, add the neuron IDs
        if g != nothing
            child_genes[g.inno_nb] = g
            if !(g.origin in neuron_pos)
                push!(neuron_pos, g.origin)
            end
            # Add out_neuron if not already in
            if !(g.destination in neuron_pos)
                push!(neuron_pos, g.destination)
            end
        end
    end

    for i in -n_in:n_out
        if !(1.0*i in neuron_pos)
            push!(neuron_pos, 1.0*i)
        end
    end

    # Set child fields
    child.genes = child_genes
    child.neuron_pos = neuron_pos
    child.fitness = -Inf .* ones(cfg["d_fitness"])
    child.network = Network(n_in, n_out, Dict())
    child.activ_functions = merge(p2.activ_functions, p1.activ_functions)
    build!(child)
    child
end
