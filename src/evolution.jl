export NEAT

function NEAT(cfg::Dict, fitness::Function)
    evaluate!::Function = e::Evolution->NEAT_evaluate!(e, fitness)
    selection::Function = i::Array{NEATIndiv} -> NEAT_tournament(i, cfg["tournament_size"])
    populate!::Function  = e::Evolution->NEAT_populate!(e, selection)
    Evolution(NEATIndiv, cfg; evaluate=evaluate!, populate=populate!)
end
