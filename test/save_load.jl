cfg = get_config("../cfg/hyperneat.yaml")

@testset "Save / Load" begin
    e = NEAT(cfg, fitness_xor, cfg["n_in"])
    Cambrian.step!(e)
end
