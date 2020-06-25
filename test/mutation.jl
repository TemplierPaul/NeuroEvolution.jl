cfg_control = get_config("test.yaml")
cfg["n_out"]=1

ind = NEATIndiv(cfg)
ind_control = NEATIndiv(ind)
@test test_identical(ind, ind_control)

@testset "Mutation Weight" begin
    cfg = get_config("test.yaml")
    cfg["n_out"]=1
    cfg["p_mut_weights"]=1
    ind_mut = mutate_weight(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
    test_process(ind_mut, cfg)
end

@testset "Mutation Add connection" begin
    cfg = get_config("test.yaml")
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
    for i in 1:100
        i = rand(-10:0)
        j = rand(1:10)
        n = random_position(1.0*i, 1.0*j)
        @test n < j
        @test n > i
        @test n > 0.0
        @test n < 1.0
    end
    # Recurrent
    for i in 1:100
        i = rand(1:10)
        j = rand(-10:0)
        n = random_position(1.0*i, 1.0*j)
        @test n < i
        @test n > j
        @test n > 0.0
        @test n < 1.0
    end
end

@testset "Mutation Add neuron" begin
    cfg = get_config("test.yaml")
    cfg["n_out"]=1
    ind_mut = mutate_neuron(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
    @test length(ind.neuron_pos) < length(ind_mut.neuron_pos)
    test_process(ind_mut, cfg)
end

@testset "Mutation Enable" begin
    cfg = get_config("test.yaml")
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
    cfg = get_config("test.yaml")
    cfg["n_out"]=1
    cfg["p_mutate_enabled"] = 1 # Ensure there is a mutation
    cfg["p_mut_weights"]=1 # Ensure weights mutation really happens
    ind_mut = mutate(ind, cfg)
    @test test_identical(ind, ind_control)
    @test !test_identical(ind, ind_mut)
    test_process(ind_mut, cfg)
end
