export NEAT

function NEAT(cfg::Dict, fitness::Function)
    evaluate = x::Evolution->Cambrian.fitness_evaluate!(x; fitness=fitness)
    Evolution(NEATIndiv, cfg; evaluate=evaluate, populate=NEAT_populate!)
end
