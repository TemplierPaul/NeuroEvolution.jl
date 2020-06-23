cfg = get_config("test.yaml")

ind = NEATIndiv(cfg)
ind_control = NEATIndiv(ind)
@test test_identical(ind, ind_control)

@testset "Mutation Weight" begin
    ind_mut = mutate_weight(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
end

@testset "Mutation Add connection" begin
    ind_mut = mutate_connect(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
    @test length(ind.genes) < length(ind_mut.genes)
end

@testset "Mutation Add neuron" begin
    ind_mut = mutate_neuron(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
    @test length(ind.neuron_pos) < length(ind_mut.neuron_pos)
end

@testset "Mutation Enable" begin
    ind_mut = mutate_enable(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
    @test ind.enabled = !ind_mut.enabled
end

@testset "Mutation" begin
    ind_mut = mutate(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
end
