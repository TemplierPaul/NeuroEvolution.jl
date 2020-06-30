cfg = get_config("hyperneat.yaml")

@testset "HyperNEAT Layer" begin
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
    net = GridNetwork(cfg)
    @test length(net.layers)==length(cfg["hn_layers"])
    if cfg["hn_link_all_layers"]
        @test length(net.connections)==factorial(length(cfg["hn_layers"])-1)
    else
        @test length(net.connections)==length(cfg["hn_layers"])-1
    end
    X = zeros(cfg["hn_layers"][1]) .+ 1
    y = process(net, X)
    @test length(y) == cfg["hn_layers"][end]
    @test !all(y .== 0.)
end

@testset "HyperNEAT Evaluate" begin
    e::Evolution = HyperNEAT(cfg, fitness_xor, 2)
    e.evaluate(e)
    @test all(getfield.(e.population, :fitness) .!= [-Inf])
end

@testset "HyperNEAT run" begin
    cfg = get_config("hyperneat.yaml")

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
        println("\nBest individuals: ", getfield.(best[1:10], :fitness))
        println("\n\n", best[1])
    end



end
