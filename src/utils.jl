function rand_weight()
    rand() * 2.0 - 1.0 # initial weight is uniformly distributed between -1 and 1
end

function activation(x::Float64)
    1 / (1 + exp(-x))
end
