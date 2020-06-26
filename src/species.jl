export Species, add!, renew!, belongs_to_species, find_species!, compute_fitness_mean!, compute_fitness_max!

mutable struct Species
    id::Int64
    age::Int64
    members::Array{NEATIndiv}
    previous_members::Array{NEATIndiv}
    dist_threshold::Float64
    fitness_val::Float64
end

"Creates a new species from a config dict and stores it"
function Species(cfg::Dict)
    cfg["species_max"] += 1 # New species ID
    s = Species(cfg["species_max"], 0, [], [], cfg["dist_threshold"], 0.0)  # Create empty species
    cfg["Species"][cfg["species_max"]] = s   # Store new species in cfg
    s
end

"Adds indiv to the current members of species s"
function add!(s::Species, indiv::NEATIndiv)
    push!(s.members, indiv)
end

"Empties the list of members if the species has any, and stores them as previous_members"
function renew!(s::Species)
    if length(s.members) > 0
        s.previous_members = s.members
        s.members = []
    end
end

"Returns true if indiv is close enough to s, else false"
function belongs_to_species(s::Species, indiv::NEATIndiv, cfg::Dict)
    if length(s.previous_members) > 0 # Compare first to the alive individuals
        rand_indiv = rand(s.previous_members)
    elseif length(s.members) > 0 # Else compare to last dead ones
        rand_indiv = rand(s.members)
    else # If both are empty, the species is empty
        return true
    end

    distance(indiv, rand_indiv, cfg) <= s.dist_threshold
end

"
Assigns indiv to the first species that matches.
If no species match, creates a new one.
"
function find_species!(indiv::NEATIndiv, cfg::Dict)
    for s in values(cfg["Species"])
        if belongs_to_species(s, indiv, cfg)
            add!(s, indiv)
            return true
        end
    end
    # If no species fits, create a new one
    new_s = Species(cfg)
    add!(new_s, indiv)
    return true
end

"Computes fitness for each member with explicit fitness sharing, returns mean fitness."
function compute_fitness_mean!(s::Species, fitness::Function)
    if length(s.members)==0
        s.fitness_val
        return 0
    end
    s_size = length(s.members) # Species size
    total_fit = 0
    for i in s.members
        f = fitness(i) ./s_size # Explicit fitness sharing
        i.fitness .=  f
        total_fit += f[1] # Compute total adjusted fitness in species
    end

    s.fitness_val = total_fit /s_size # Compute average adjusted fitness in species
    s.fitness_val
end

"Computes fitness for each member with explicit fitness sharing, returns max fitness."
function compute_fitness_max!(s::Species, fitness::Function)
    if length(s.members)==0
        s.fitness_val
        return 0
    end
    s_size = length(s.members) # Species size
    s.fitness_val = 0
    total_fit = 0
    for i in s.members
        f = fitness(i) ./ s_size # Explicit fitness sharing
        i.fitness .=  f
        s.fitness_val = maximum([s.fitness_val, f[1]])  # Compute max adjusted fitness in species
        total_fit += f[1]
    end
    s.fitness_val
end

"Creates n_children offsprings by crossover or mutation"
function reproduction!(
    s::Species,
    selection::Function,
    n_children::Int64,
    cfg::Dict,
)
    s.age += 1
    renew!(s)
    for i = 1:n_children
        if rand() < cfg["p_mutate_only"] || length(s.previous_members)==1
            # Mutate only
            p1 = selection(s.previous_members)
            child = mutate(p1, cfg)
        else
            # Crossover
            p1 = selection(s.previous_members)
            p2 = selection(s.previous_members)
            if p1 != p2
                child = crossover(p1, p2, cfg)
                child = mutate(child, cfg)
            else
                # If the same individual is chosen twice, mutate it
                child = mutate(p1, cfg)
            end
        end
        add!(s, child)
    end

end
