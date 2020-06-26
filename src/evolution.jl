export NEAT

function NEAT(cfg::Dict, fitness::Function)
    evaluate!::Function = e::Evolution->NEAT_evaluate!(e, fitness)
    Evolution(NEATIndiv, cfg; evaluate=evaluate!, populate=NEAT_populate!)
end
