cfg_control = NeuroEvolution.get_config("../cfg/test.yaml")
cfg["n_out"]=1

ind = NEATIndiv(cfg)
ind_control = NEATIndiv(ind)
@test test_identical(ind, ind_control)

@testset "Mutation Weight" begin
    cfg = NeuroEvolution.get_config("../cfg/test.yaml")
    cfg["n_out"]=1
    cfg["p_mut_weights"]=1
    ind_mut = mutate_weight(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
    test_process(ind_mut, cfg)
end

@testset "Mutation Add connection" begin
    cfg = NeuroEvolution.get_config("../cfg/test.yaml")
    cfg["n_out"]=1
    ind_mut = mutate_connect(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
    @test length(ind.genes) < length(ind_mut.genes)
    @test cfg["innovation_max"] > cfg_control["innovation_max"]
    test_process(ind_mut, cfg)
end

@testset "New neuron position" begin
    # Not recurrent
    i = 1.0.*rand(-10:0, 100)
    j = 1.0.*rand(1:10, 100)
    n = random_position.(i, j)
    @test all(n .< j)
    @test all(n .> i)
    @test all(n .> 0.0)
    @test all(n .< 1.0)

    # Recurrent
    i = rand(1:10, 100)
    j = rand(-10:0, 100)
    n = random_position.(1.0*i, 1.0*j)
    @test all(n .< i)
    @test all(n .> j)
    @test all(n .> 0.0)
    @test all(n .< 1.0)
end

@testset "Mutation Add neuron" begin
    cfg = NeuroEvolution.get_config("../cfg/test.yaml")
    cfg["n_out"]=1
    ind_mut = mutate_neuron(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
    @test length(ind.neuron_pos) < length(ind_mut.neuron_pos)
    test_process(ind_mut, cfg)
end

@testset "Mutation Enable" begin
    cfg = NeuroEvolution.get_config("../cfg/test.yaml")
    cfg["n_out"]=1
    ind_mut = mutate_enabled(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
    enabled = true
    for g in values(ind_mut.genes)
        enabled &= g.enabled
    end
    @test ! enabled
    test_process(ind_mut, cfg)
end

@testset "Mutation" begin
    cfg = NeuroEvolution.get_config("../cfg/test.yaml")
    cfg["n_out"]=1
    cfg["p_mutate_enabled"] = 1 # Ensure there is a mutation
    cfg["p_mut_weights"]=1 # Ensure weights mutation really happens
    ind_mut = mutate(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
    test_process(ind_mut, cfg)
end
