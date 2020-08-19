cfg = NeuroEvolution.get_config("../cfg/test.yaml")

@testset "Species" begin
    @test typeof(cfg["Species"])==Dict{Any,Any}
    @test length(cfg["Species"])==0
    ind = NEATIndiv(cfg)
    find_species!(ind, cfg)
    @test length(cfg["Species"])==1
    @test cfg["species_max"] == 1
end
