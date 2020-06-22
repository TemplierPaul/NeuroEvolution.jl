using JuNEAT
using Cambrian
using Test

function test_identical(ind::NEATIndiv, ind2::NEATIndiv)
    @test ind.n_in == ind2.n_in
    @test ind.n_out == ind2.n_out
    @test ind.n_hidden == ind2.n_hidden

    for i in eachindex(ind.connections)
        @test ind.connections[i].in_node == ind2.connections[i].in_node
        @test ind.connections[i].out_node == ind2.connections[i].out_node
        @test ind.connections[i].weight == ind2.connections[i].weight
        @test ind.connections[i].enabled == ind2.connections[i].enabled
        @test ind.connections[i].innovation == ind2.connections[i].innovation
    end

    @test all(ind.fitness .== ind2.fitness)
end

include("individual.jl")
include("process.jl")
include("mutation.jl")
