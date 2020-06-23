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
    same::Bool=true
    same &= g1.inno_nb == g2.inno_nb
    same &= g1.origin == g2.origin
    same &= g1.destination == g2.destination
    same &= g1.weight == g2.weight
    same &= g1.activated == g2.activated
    same
end

function test_identical(ind::NEATIndiv, ind2::NEATIndiv)
    same::Bool=true
    same &= length(ind.genes) == length(ind2.genes)
    same &= length(ind.neuron_pos) == length(ind2.neuron_pos)
    same &= all(ind.fitness .== ind2.fitness)

    for i in eachindex(ind.genes)
        same &= test_identical(ind.genes[i], ind2.genes[i])
    end

    for i in eachindex(ind.neuron_pos)
        same &=  ind.neuron_pos == ind2.neuron_pos
    end

    same &=  all(ind.fitness .== ind2.fitness)
    same
end

include("individual.jl")
include("xor.jl")

include("network.jl")
include("mutation.jl")
