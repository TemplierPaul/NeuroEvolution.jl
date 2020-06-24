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

    ind3 = NEATIndiv(cfg)
    test_indiv(ind3, cfg)
    @test !test_identical(ind, ind3)
    @test cfg["innovation_max"]==n_in * n_out

    @test distance(ind, ind, cfg)  ==0.
    @test distance(ind2, ind, cfg) ==0.
    @test distance(ind, ind3, cfg) != 0.
    @test distance(ind, ind3, cfg) == distance(ind3, ind, cfg)
end
