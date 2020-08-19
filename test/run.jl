cfg = NeuroEvolution.get_config("../cfg/test.yaml")
cfg["n_out"] = 1
cfg["n_in"] = 2
cfg["log_gen"] = 0
cfg["save_gen"] = 0

@testset "Evolution creation" begin
    # test_fitness::Function = x::NEATIndiv -> fitness_xor(x, cfg["n_in"])
    e::Evolution = NEAT(cfg, fitness_xor, cfg["n_in"])
    # @test length(e.population) == cfg["n_population"]
    @test all(typeof.(e.population) .== NEATIndividual)
end

@testset "Evaluate" begin
    # test_fitness::Function = x::NEATIndiv -> fitness_xor(x, cfg["n_in"])
    e::Evolution = NEAT(cfg, fitness_xor, cfg["n_in"])
    e.evaluate(e)
    @test all(getfield.(e.population, :fitness) .!= [-Inf])
end

@testset "Populate" begin
    cfg = NeuroEvolution.get_config("../cfg/test.yaml")
    # test_fitness::Function = x::NEATIndiv -> fitness_xor(x, cfg["n_in"])
    e::Evolution = NEAT(cfg, fitness_xor, cfg["n_in"])
    e.evaluate(e)
    e.populate(e)
    @test length(e.population) > 0
end

@testset "NEAT on XOR" begin
    cfg = NeuroEvolution.get_config("../cfg/test.yaml")

    # Run evolution
    # test_fitness::Function = x::NEATIndiv -> fitness_xor(x, cfg["n_in"])
    e = NEAT(cfg, fitness_xor, cfg["n_in"])
    Cambrian.run!(e)

    # @test length(e.population) == cfg["n_population"]

    X, y = xor_dataset(cfg["n_in"], 100)
    max_f = sum(log_fitness.(y, y)) / length(X)
    y_false = []
    for i in y
        push!(y_false, 1 .- i)
    end
    min_f = sum(log_fitness.(y, y_false)) / length(X)
    if cfg["verbose"]
        println("\n-- NEAT on XOR --")
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
        println("\nBest individuals: ", getfield.(best[1:10], :fitness), "\n")
        println("\n\n", best[1])
    end
end

@testset "Cambrian.GA x NEAT" begin
    cfg = NeuroEvolution.get_config("../cfg/ga.yaml")

    e = GA_NEAT(NEATIndividual, cfg, fitness_xor; id="test")
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
