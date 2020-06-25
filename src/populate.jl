export NEAT_populate!

function NEAT_populate!(
    e::Evolution;
    selection::Function = x ->
        tournament_selection(x, e.cfg["tournament_size"]),
)
    # Assign species
    if length(cfg["Species"]) == 0
        s = Species(cfg)
    end
    find_species!.(e.population)

    # Compute fitness
    total_fitness = 0
    for s in values(e.cfg.species)
        total_fitness += compute_fitness!(s, fitness)
    end

    # Create offsprings and add to the population
    new_pop::Array{NEATIndiv}=[]
    for s in values(e.cfg.species)
        nb_offspring = Integer(s.total_fitness / total_fitness)
        reproduction!(s, selection, nb_offspring, cfg)
        append!(new_pop, s.members)
    end
end
