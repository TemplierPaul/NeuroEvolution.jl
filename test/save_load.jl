using NeuroEvolution
using Cambrian
using JSON
include("xor.jl")

cfg = get_config("../cfg/test.yaml")
id = "011fc676-b63a-438a-a19a-4c9fc91a052b"

@testset "Save / Load NEATIndividual" begin
    ind = NEATIndividual(cfg)
    build!(ind)
    s = string(ind)
    new_ind = NEATIndiv(cfg, s)

    @test typeof(new_ind) == NEATIndividual
    build!(new_ind)
end

@testset "Save / Load HyperNEATIndividual" begin
    hn_cfg = get_config("../cfg/hyperneat.yaml")
    ind = HyperNEATIndividual(hn_cfg)
    build!(ind)
    s = string(ind)
    new_ind = NEATIndiv(hn_cfg, s)

    @test typeof(new_ind) == HyperNEATIndividual
    build!(new_ind)
end

@testset "Save population" begin
    e = NEAT(cfg, fitness_xor, cfg["n_in"])
    id = e.id
    step!(e)
    Cambrian.save_gen(e)
    l = readdir("gens/$(e.id)/0001")
    @test length(l) > 0
end

@testset "Load population" begin
    e = NEAT(cfg, fitness_xor, cfg["n_in"])
    load_gen!(e, "$id/0001")
    @test all(getfield.(e.population, :fitness) .!= [-Inf])
    step!(e)
end
