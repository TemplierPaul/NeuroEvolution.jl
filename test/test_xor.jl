include("xor.jl")

@testset "XOR data generator" begin
    a = rand_bin(20)
    @test length(a) == 20
    @test all(a.<=1)
    @test all(a.>=0)
    @test all(typeof.(a) .== Float64)

    b = xor(a)
    @test all(typeof.(b) .== Float64)
    @test length(b) == 1

    X, y = xor_dataset(20, 100)
    @test length(X)==100
    @test length(y)==100
    @test length(X[1])==20
    @test all(typeof.(y[1]) .== Float64)

    @test all(xor.(X) .== y)
end

@testset "Log Loss" begin
    @test log_loss(0, 0) < 0.01
    @test log_loss(0, 1) > 0
    @test log_loss(1, 1) < 0.01
    @test log_loss(1, 0) > 0

    X, y = xor_dataset(20, 100)
    @test sum(log_loss.(y, y)) < 0.1
end
