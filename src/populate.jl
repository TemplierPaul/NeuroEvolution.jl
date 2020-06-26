export NEAT_populate!, NEAT_evaluate!

function NEAT_tournament(pop::Array{NEATIndiv}, t_size::Int)
    inds = shuffle!(collect(1:length(pop)))
    sort(pop[inds[1:t_size]])[end]
end

function NEAT_populate!(
    e::Evolution;
    selection::Function = x ->
        NEAT_tournament(x, e.cfg["tournament_size"]),
)
    # Create offsprings and add to the population
    new_pop::Array{NEATIndiv}=[]
    for s in values(e.cfg["Species"])
        nb_offspring = Integer(floor(s.total_fitness / e.cfg["total_fitness"]))
        reproduction!(s, selection, nb_offspring, e.cfg)
        append!(new_pop, s.members)
    end
end

function NEAT_evaluate!(e::Evolution, fitness::Function)
    # Assign species
    if length(e.cfg["Species"]) == 0
        s = Species(e.cfg)
    end
    for i in e.population
        find_species!(i, e.cfg)
    end

    # Compute fitness
    e.cfg["total_fitness"]= 0
    for s in values(e.cfg["Species"])
        e.cfg["total_fitness"] += compute_fitness!(s, fitness)
    end

end
