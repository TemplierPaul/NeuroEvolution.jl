export Species

mutable struct Species
    id::Int64
    age::Int64
    members::Array{NEATIndiv}
    previous_members::Array{NEATIndiv}
    dist_threshold::Float64
    total_fitness::Float64
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
function belongs_to_species(s::Species, indiv::NEATIndiv)
    if len(s.previous_members) > 0 # Compare first to the alive individuals
        rand_indiv = rand(s.previous_members)
    elseif len(s.members) > 0 # Else compare to last dead ones
        rand_indiv = rand(s.members)
    else # If both are empty, the species is empty
        return true
    end

    distance(indiv, rand_indiv) <= s.dist_threshold
end

"
Assigns indiv to the first species that matches.
If no species match, creates a new one.
"
function find_species!(indiv::NEATIndiv, cfg::Dict)
    for s in values(e.cfg.species)
        if belongs_to_species(s, indiv)
            add!(s, indiv)
            return true
        end
    end
    # If no species fits, create a new one
    new_s = Species(cfg)
    add!(new_s, indiv)
    return true
end

"Computes fitness for each member with explicit fitness sharing, returns total fitness."
function compute_fitness!(s::Species, fitness::Function)
    s_size = length(s.members) # Species size
    for i in s.members
        i.fitness = fitness(i) / s_size
    end
    s.total_fitness = sum(getfield(s.members, :fitness))
    s.total_fitness
end


function reproduction!(
    s::Species,
    selection::Function,
    n_children::Int64,
    cfg::Dict,
)
    renew!(s)
    for i = 1:n_children
        if rand() < cfg["p_mutate_only"]
            # Mutate only
            p1 = selection(s.previous_members)
            child = mutate(p1)
        else
            # Crossover
            p1 = selection(s.previous_members)
            p2 = selection(s.previous_members)
            if p1 != p2
                child = crossover(p1, p2)
            else
                # If the same individual is chosen twice, mutate it
                child = mutate(p1)
            end
        end
        add!(s, child)
    end

end
