cfg = get_config("../cfg/hyperneat.yaml")

@testset "HyperNEAT Layer" begin
    cfg = get_config("../cfg/hyperneat.yaml")
    l = Layer(10, 0., cfg["hn_activ_func"])
    @test l.size == 10
    @test length(l.values)==10
    @test length(l.biases)==10
    @test l.depth == 0
end

@testset "HyperNEAT Connection" begin
    # Empty layer
    l1 = Layer(10, 0., cfg["hn_activ_func"])
    l2 = Layer(8, 1., cfg["hn_activ_func"])
    c = Connection(l1, l2)
    @test c.layer_from == l1
    @test c.layer_to == l2
    @test size(c.weights) == (10, 8)

    # Generated layer
    f = x -> rand()
    c = Connection(f, l1, l2)
    @test c.layer_from == l1
    @test c.layer_to == l2
    @test size(c.weights) == (10, 8)
end

@testset "HyperNEAT Network" begin
    # All possible connections
    cfg["hn_link_all_layers"]= true
    net = GridNetwork(cfg)
    @test length(net.layers)==length(cfg["hn_hidden_layers"])+2
    @test length(net.connections)==factorial(length(cfg["hn_hidden_layers"])+1)
    X = zeros(cfg["n_in"]) .+ 1
    y = process(net, X)
    @test length(y) == cfg["n_out"]
    @test !all(y .== 0.)
    for c in net.connections
        @test c.layer_from.depth < c.layer_to.depth
    end

    # Only feed-forward
    cfg["hn_link_all_layers"]= false
    net = GridNetwork(cfg)
    @test length(net.layers)==length(cfg["hn_hidden_layers"])+2
    @test length(net.connections)==length(cfg["hn_hidden_layers"])+1
    X = zeros(cfg["n_in"]) .+ 1
    y = process(net, X)
    @test length(y) == cfg["n_out"]
    @test !all(y .== 0.)
    for c in net.connections
        @test c.layer_from.depth < c.layer_to.depth
    end
end

@testset "HyperNEAT Evaluate" begin
    e::Evolution = HyperNEAT(cfg, fitness_xor, 2)
    e.evaluate(e)
    @test all(getfield.(e.population, :fitness) .!= [-Inf])
end

@testset "HyperNEAT run" begin
    cfg = get_config("../cfg/hyperneat.yaml")

    e = HyperNEAT(cfg, fitness_xor, 2)
    Cambrian.run!(e)

    X, y = xor_dataset(2, 100)
    max_f = sum(log_fitness.(y, y)) / length(X)
    y_false = []
    for i in y
        push!(y_false, 1 .- i)
    end
    min_f = sum(log_fitness.(y, y_false)) / length(X)
    if cfg["verbose"]
        println("\n-- HyperNEAT on XOR --")
        println("Worst possible fitness: ", min_f)
        println("Best  possible fitness: ", max_f)
    end
    # Analyse results
    best = sort(e.population, rev=true)
    @test best[1].fitness[1] <= max_f
    @test best[1].fitness[1] > min_f

    y = process(best[1], [1., 1.])
    @test typeof(y[1])==Float64

    if cfg["verbose"]
        println("Final fitness: ", best[1].fitness[1])
        println("Genome size: ", length(best[1].genes))
        println("Max innovation: ", e.cfg["innovation_max"])
        println("Species: ", length(e.cfg["Species"]))
        println("Best(0, 0)= ", y[1])
        println("\nBest individuals: ", getfield.(best[1:5], :fitness))
        println("\nConnections in Best: ")
        for g in values(best[1].genes)
            println(g.origin, " -- ", g.weight, " -> ", g.destination)

        end
    end
end

@testset "Cambrian.GA x HyperNEAT" begin
    cfg = get_config("../cfg/ga.yaml")
    cfg["hyperneat"]=true
    cfg["hn_activ_func"]=sigmoid
    e = GA_NEAT(HyperNEATIndividual, cfg, fitness_xor; id="test")
    step!(e)
    @test length(e.population) == cfg["n_population"]
    run!(e)
    best = sort(e.population, rev=true)

    X, y = xor_dataset(cfg["n_in"], 100)
    max_f = sum(log_fitness.(y, y)) / length(X)
    y_false = []
    for i in y
        push!(y_false, 1 .- i)
    end
    min_f = sum(log_fitness.(y, y_false)) / length(X)
    @test best[1].fitness[1] <= max_f
    @test best[1].fitness[1] > min_f

    y = process(best[1], [1., 1.])
    @test typeof(y[1])==Float64
end
