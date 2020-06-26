export NEAT_populate!, NEAT_evaluate!

function NEAT_tournament(pop::Array{NEATIndiv}, t_size::Int)
    if length(pop) == 1
        return pop[1]
    end
    inds = shuffle!(collect(1:length(pop)))
    sort(pop[inds[1:t_size]])[end]
end

function NEAT_populate!(e::Evolution, selection::Function)
    # Create offsprings and add to the population
    new_pop::Array{NEATIndiv} = []
    # println("\n-------\nTotal fitness: ", e.cfg["total_fitness"], " Pop: ", length(e.population))
    for s in values(e.cfg["Species"])
        # println("\nFitness: ", s.fitness_val, " Members: ", length(s.members))
        nb_offspring = Integer(round(
            length(e.population) * s.fitness_val / e.cfg["total_fitness"],
        ))
        # println("Children: ", nb_offspring)
        reproduction!(s, selection, nb_offspring, e.cfg)
        append!(new_pop, s.members)
    end

    e.population = new_pop
    println("Pop: ", length(e.population), "  Species: ", length(e.cfg["Species"]), " Inno: ", e.cfg["innovation_max"])
end

function NEAT_evaluate!(e::Evolution, fitness::Function)
    # Assign species
    if length(e.cfg["Species"]) == 0
        s = Species(e.cfg)
    end
    for i in e.population
        find_species!(i, e.cfg)
    end

    # update distance threshold to keep species number stable
    update_threshold!(e.cfg)

    # Compute fitness
    e.cfg["total_fitness"] = 0
    if e.cfg["use_max_fitness"]
        for s in values(e.cfg["Species"])
            e.cfg["total_fitness"] +=
                compute_fitness_max!(s, fitness)
        end
    else
        for s in values(e.cfg["Species"])
            e.cfg["total_fitness"] +=
                compute_fitness_mean!(s, fitness)
        end
    end
end

function update_threshold!(cfg::Dict)
    nb_species = length(cfg["Species"])
    if nb_species < cfg["target_species_number"]
        cfg["dist_threshold"] -= cfg["dist_mod"]
    elseif nb_species > cfg["target_species_number"]
        cfg["dist_threshold"] += cfg["dist_mod"]
    end
    if cfg["dist_threshold"] < cfg["dist_mod"]
        cfg["dist_threshold"] = cfg["dist_mod"]
    end
end
