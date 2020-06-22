using JuNEAT
using Cambrian
using Test

function test_identical(neur1::Neuron, neur2::Neuron)
    @test neur1.position == @test neur2.position
    @test neur1.activ_func == @test neur2.activ_func
    @test neur1.input == @test neur2.input
    @test neur1.output == @test neur2.output
end

function test_identical(g1::Gene, g2::Gene)
    @test g1.inno_nb == g2.inno_nb
    @test g1.origin == g2.origin
    @test g1.destination == g2.destination
    @test g1.weight == g2.weight
    @test g1.activated == g2.activated
end

function test_identical(ind::NEATIndiv, ind2::NEATIndiv)
    @test length(ind.genes) == length(ind2.genes)
    @test length(ind.neuron_pos) == length(ind2.neuron_pos)
    @test all(ind.fitness .== ind2.fitness)

    for i in eachindex(ind.genes)
        test_identical(ind.genes[i], ind2.genes[i])
    end

    for i in eachindex(ind.neuron_pos)
        @test ind.neuron_pos == ind2.neuron_pos
    end

    @test all(ind.fitness .== ind2.fitness)
end

include("individual.jl")
# include("network.jl")
# include("process.jl")
# include("mutation.jl")
