export Gene

mutable struct Gene
    inno_nb::Integer
    origin::Float64
    destination::Float64
    weight::Float64
    enabled::Bool
end

function Gene(origin::Float64, destination::Float64, inno::Integer)
    w = rand_weight()
    Gene(inno, origin, destination, w, true)
end

function Gene(g::Gene)
    deepcopy(g)
end

function Gene(d::Dict{String,Any})
    Gene(
        d["inno_nb"],
        d["origin"],
        d["destination"],
        d["weight"],
        d["enabled"],
    )
end
