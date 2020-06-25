export random_position

function rand_weight()
    rand() * 2.0 - 1.0 # initial weight is uniformly distributed between -1 and 1
end

function random_position(origin::Float64, destination::Float64)
    n_min = maximum([0, minimum([origin, destination])])
    n_max = minimum([1, maximum([origin, destination])])
    n = n_min + rand() * (n_max - n_min)
    n
end

function sigmoid(x::Float64)
    1 / (1 + exp(-5*x))
end

function ReLU(x::Float64)
    if x <0
        0
    else
        x
    end
end

function identity_activ(x::Float64)
    x
end

function gauss(x::Float64)
    exp(-5.0 * x^2)
end

function tanh_activ(x::Float64)
    tanh(2.5 * x)
end
