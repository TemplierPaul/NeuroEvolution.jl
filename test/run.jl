cfg = get_config("test.yaml")
cfg["n_out"] = 1
cfg["n_in"] = 2
cfg["log_gen"] = 0
cfg["save_gen"] = 0

@testset "Evolution creation" begin
    test_fitness::Function = x::NEATIndiv -> fitness_xor(x, cfg["n_in"])
    e::Evolution = NEAT(cfg, test_fitness)
    # @test length(e.population) == cfg["n_population"]
    @test all(typeof.(e.population) .== NEATIndiv)
end

@testset "Evaluate" begin
    test_fitness::Function = x::NEATIndiv -> fitness_xor(x, cfg["n_in"])
    e::Evolution = NEAT(cfg, test_fitness)
    e.evaluate(e)
    @test all(getfield.(e.population, :fitness) .!= [-Inf])
end

@testset "Populate" begin
    test_fitness::Function = x::NEATIndiv -> fitness_xor(x, cfg["n_in"])
    e::Evolution = NEAT(cfg, test_fitness)
    e.evaluate(e)
    e.populate(e)
    @test length(e.population) > 0
end

@testset "NEAT on XOR" begin
    cfg = get_config("test.yaml")

    #
    println("\n-- NEAT on XOR --")
    X, y = xor_dataset(cfg["n_in"], 100)
    max_f = sum(log_fitness.(y, y)) / length(X)
    println("Best  possible fitness: ", max_f)
    y_false = []
    for i in y
        push!(y_false, 1 .- i)
    end
    min_f = sum(log_fitness.(y, y_false)) / length(X)
    println("Worst possible fitness: ", min_f)

    # Run evolution
    test_fitness::Function = x::NEATIndiv -> fitness_xor(x, cfg["n_in"])
    e = NEAT(cfg, test_fitness)
    println("Min innovation: ", e.cfg["innovation_max"])
    Cambrian.run!(e)
    # @test length(e.population) == cfg["n_population"]

    # Analyse results
    best = sort(e.population, rev=true)
    println("Final fitness: ", best[1].fitness[1])
    @test best[1].fitness[1] <= max_f
    println("Genome size: ", length(best[1].genes))
    println("Max innovation: ", e.cfg["innovation_max"])
    println("Species: ", length(e.cfg["Species"]))
    println("\nBest individuals: ", getfield.(best[1:10], :fitness), "\n")

    println("\n\n", best[1])

end
