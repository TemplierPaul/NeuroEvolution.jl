function xor(a::Int64, b::Int64)
    if a + b == 1
        1
    else
        0
    end
end

function xor(a::Array{Int64})
    v = a[1]
    for i in 2:length(a)
        v = xor(v, a[i])
    end
    v
end

function rand_bin(len::Int64)
    rand(0:1, len)
end

function xor_dataset(n_records::Int64, len::Int64)
    X::Array{Array{Int64}}=[]
    y::Array{Int64}=[]
    for i in 1:n_records
        l = rand_bin(len)
        push!(X, l)
        push!(y, xor(l))
    end
    X, y
end

@testset "XOR data generator" begin
    a = rand_bin(20)
    @test length(a) == 20
    @test all(a.<=1)
    @test all(a.>=0)
    @test all(typeof.(a) .== Int64)

    b = xor(a)
    @test typeof(b) == Int64

    X, y = xor_dataset(100, 20)
    @test length(X)==100
    @test length(y)==100
    @test length(X[1])==20
    @test typeof(y[1]) == Int64

    @test all(xor.(X) .== y)
end
