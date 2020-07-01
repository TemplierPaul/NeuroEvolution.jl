export NEAT, HyperNEAT, GA_NEAT

"""
fitness::Function i::NEATIndiv -> computed_fitness(i)
"""

function core_NEAT(itype::Type, cfg::Dict, fitness::Function)
    evaluate!::Function = e::Evolution -> NEAT_evaluate!(e, fitness)
    selection::Function = i::Array{NEATIndiv} -> i[1]
    if cfg["selection_type"] == "tournament"
        selection =
            i::Array{NEATIndiv} -> NEAT_tournament(i, cfg["tournament_size"])
    elseif cfg["selection_type"] == "random_top"
        selection =
            i::Array{NEATIndiv} -> NEAT_random_top(i, cfg["survival_threshold"])
    else
        throw(ArgumentError("Wrong selection type: " + cfg["selection_type"]))
    end
    populate!::Function = e::Evolution -> NEAT_populate!(e, selection)
    Evolution(itype, cfg; evaluate = evaluate!, populate = populate!)
end

function NEAT(cfg::Dict, fitness::Function, fitness_args...)
    f::Function = i::NEATIndividual -> fitness(i, fitness_args...)
    core_NEAT(NEATIndividual, cfg, f)
end

function HyperNEAT(cfg::Dict, fitness::Function, fitness_args...)
    f::Function = i::HyperNEATIndividual -> fitness(i, fitness_args...)
    core_NEAT(HyperNEATIndividual, cfg, f)
end

## Genetic Algorithm with NEAT individuals

function GA_NEAT(itype::Type, cfg::Dict, fitness::Function; kwargs...)
    # Build before evaluation
    function evaluate(e::Evolution)
        build!.(e.population)
        Cambrian.fitness_evaluate!(e; fitness = fitness)
    end

    # Force NEAT mutation and crossover operators
    function neat_ga_populate!(e::Evolution)
        mut::Function = i::NEATIndiv -> NeuroEvolution.mutate(i, e.cfg)
        cross::Function = (p1, p2) -> NeuroEvolution.crossover(p1, p2, e.cfg)
        Cambrian.ga_populate!(e, mutation = mut, crossover = cross)
    end

    Evolution(itype, cfg; evaluate = evaluate, populate = neat_ga_populate!)
end
