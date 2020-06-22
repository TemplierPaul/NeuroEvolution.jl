mutable struct Gene
    inno_nb::Integer
    origin::Float64
    destination::Float64
    weight::Float64
end

function Gene(origin::Float64, destination::Float64, cfg::Dict)
    body
end

function Gene(g:Gene)
    deepcopy(g)
end
