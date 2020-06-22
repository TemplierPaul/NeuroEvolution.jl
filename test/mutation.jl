cfg = get_config("test.yaml")
cfg["innovation_max"] = 5
cfg["p_mut_weights"] = 1.0

ind = NEATInd(cfg)
clone = deepcopy(ind)

@testset "Mutate" begin
    mut_w = NEAT.mutate_weights(ind, cfg)
    @test length(mut_w.connections) == length(ind.connections)
    for ci in eachindex(mut_w.connections)
        @test mut_w.connections[ci].in_node == ind.connections[ci].in_node
        @test mut_w.connections[ci].out_node == ind.connections[ci].out_node
        @test mut_w.connections[ci].weight != ind.connections[ci].weight
    end
    # test that mutation didn't effect ind
    test_identical(ind, clone)

    # add a neuron
    mut_add_neur = NEAT.mutate_add_neuron(ind, cfg)
    @test length(mut_add_neur.connections) == length(ind.connections) + 1
    @test length(mut_add_neur.neurons) == length(ind.neurons) + 1
    @test length(clone.connections) == length(ind.connections)
    @test length(clone.neurons) == length(ind.neurons)
    test_identical(ind, clone)

    # add a connection to original network, no change expected
    mut_add_con = NEAT.mutate_add_connection(ind, cfg)
    @test length(mut_add_con.connections) == length(mut_add_neur.connections)
    test_identical(ind, mut_add_con)

    # add connection to network with additional neuron, expect new connection
    clone2 = deepcopy(mut_add_neur)
    mut_add_con = NEAT.mutate_add_connection(mut_add_neur, cfg)
    @test length(mut_add_con.connections) == length(mut_add_neur.connections) + 1
    test_identical(mut_add_neur, clone2)

    # toggle enabled on n_times connections (not really used in practice)
    mut_en = NEAT.mutate_enabled(ind; n_times=length(ind.connections))
    @test length(mut_en.connections) == length(ind.connections)
    for ci in eachindex(mut_en.connections)
        @test mut_en.connections[ci].enabled != ind.connections[ci].enabled
    end
    test_identical(ind, clone)

    # mutate
    mut = mutate(ind, cfg)
    @test mut.n_in == ind.n_in
    @test mut.n_out == ind.n_out
    test_identical(ind, clone)
end
