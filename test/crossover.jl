cfg = get_config("test.yaml")

@testset "Crossover" begin
    p1 = NEATIndiv(cfg)

    p2 = NEATIndiv(cfg)
    p2 = mutate_neuron(p2, cfg)
    p2.fitness = [0.]

    @test !test_identical(p1, p2)
    p1_control = NEATIndiv(p1)
    p2_control = NEATIndiv(p2)
    @test test_identical(p1, p1_control)
    @test test_identical(p2, p2_control)

    child = crossover(p1, p2, cfg)
    @test !test_identical(p1, child)
    @test !test_identical(p2, child)

    test_process(child, cfg)
end
