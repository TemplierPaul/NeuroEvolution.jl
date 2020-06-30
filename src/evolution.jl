export NEAT, HyperNEAT

"""
fitness::Function i::NEATIndiv -> computed_fitness(i)
"""

function core_NEAT(cfg::Dict, fitness::Function)
    evaluate!::Function = e::Evolution->NEAT_evaluate!(e, fitness)
    selection::Function = i::Array{NEATIndiv} -> i[1]
    if cfg["selection_type"] == "tournament"
        selection = i::Array{NEATIndiv} -> NEAT_tournament(i, cfg["tournament_size"])
    elseif cfg["selection_type"] == "random_top"
        selection = i::Array{NEATIndiv} -> NEAT_random_top(i, cfg["survival_threshold"])
    else
        throw(ArgumentError("Wrong selection type: " + cfg["selection_type"]))
    end
    populate!::Function  = e::Evolution->NEAT_populate!(e, selection)
    Evolution(NEATIndiv, cfg; evaluate=evaluate!, populate=populate!)
end

function NEAT(cfg::Dict, fitness::Function, fitness_args...)
    f::Function = i::Individual -> NEAT_fitness(i, fitness, fitness_args...)
    core_NEAT(cfg, f)
end

function HyperNEAT(cfg::Dict, fitness::Function, fitness_args...)
    cfg["n_in"]=4
    cfg["n_out"]=1
    f::Function = i::Individual -> HyperNEAT_fitness(i, fitness, fitness_args...;cfg=cfg)
    core_NEAT(cfg, f)
end
