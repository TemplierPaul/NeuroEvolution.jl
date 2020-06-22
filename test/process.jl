
cfg = get_config("test.yaml")

function test_individual(ind::NEATInd)
    inputs = zeros(cfg["n_in"])

    set_inputs(ind, inputs)
    @test ind.neurons[1].output == inputs[1]

    outputs = get_outputs(ind)
    @test length(outputs) == cfg["n_out"]
    @test all(outputs .== 0.0)

    outputs = process(ind, inputs)
    @test length(outputs) == cfg["n_out"]
    @test any(outputs .!= 0.0)
    @test all(outputs .>= 0.0)
    @test all(outputs .<= 1.0)

    inputs = 10 .* rand(cfg["n_in"])
    outputs = process(ind, inputs)
    @test any(outputs .!= 0.0)
    @test all(outputs .>= 0.0)
    @test all(outputs .<= 1.0)
end

@testset "Processing individuals" begin
    ind = NEATInd(cfg)
    test_individual(ind)

    # TODO: add after mutation is done
    # ind2 = mutate_add_node(cfg, ind)
    # test_individual(ind2)

    # ind3 = mutate_add_link(cfg, ind)
    # test_individual(ind3)
end
