export crossover

function crossover(parent1::NEATIndiv, parent2::NEATIndiv, cfg::Dict)
    # get p1 parent with best fitness to keep its genes
    p1, p2 = sort([parent1, parent2], by=x -> x.fitness[1], rev=true)
    child = NEATIndiv(p1)

    # Child connections
    child_genes=Dict()
    neuron_pos::Array{Float64}=[]
    for i in 1:cfg["innovation_max"]
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

    # Set child fields
    child.genes = child_genes
    child.neuron_pos = neuron_pos
    child.fitness = -Inf .* ones(cfg["d_fitness"])
    child.network = Network(cfg["n_in"], cfg["n_out"], Dict())
    child.activ_functions = merge(p2.activ_functions, p1.activ_functions)
    child
end
