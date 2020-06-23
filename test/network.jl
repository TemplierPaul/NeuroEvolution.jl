cfg = get_config("test.yaml")

@testset "Network" begin

    n = Network(3, 5, Dict())
    @test length(n.neurons) == 0

    n_in = cfg["n_in"]
    n_out = cfg["n_out"]
    ind = NEATIndiv(cfg)
    @test length(ind.network.neurons) == 0
    @test ind.network.n_in == n_in
    @test ind.network.n_out == n_out

    build!(ind)
    @test length(ind.network.neurons) == n_in + n_out + 1
    @test length(ind.network.neurons) == length(ind.neuron_pos)
    @test ind.network.n_in == n_in
    @test ind.network.n_out == n_out

    # Processing 1 input
    x = rand_bin(n_in)
    y = process(ind, x)
    @test length(y)==n_out
    @test all(typeof.(y) .==Float64)

    # Processing an array of inputs
    X, Y = xor_dataset(n_in, 100)
    y = process(ind, X)
    @test length(y)==100
    @test length(y[1])==n_out
end
