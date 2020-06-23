cfg = get_config("test.yaml")

function test_indiv(ind::NEATIndiv, cfg::Dict)
    n_in = cfg["n_in"]
    n_out = cfg["n_out"]
    @test length(ind.genes) == n_in * n_out
    @test length(ind.fitness) == cfg["d_fitness"]
    @test all(ind.fitness .== -Inf)
    @test length(ind.neuron_pos) == n_in + n_out + 1
end

@testset "Individual" begin
    n_in = cfg["n_in"]
    n_out = cfg["n_out"]
    ind = NEATIndiv(cfg)
    test_indiv(ind, cfg)
    @test cfg["innovation_max"]==n_in * n_out

    ind2 = NEATIndiv(ind)
    test_indiv(ind2, cfg)
    @test cfg["innovation_max"]==n_in * n_out

    @test test_identical(ind, ind)
    @test test_identical(ind, ind2)
end
