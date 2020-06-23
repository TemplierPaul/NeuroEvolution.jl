function build(indiv::NEATIndiv)
    body
end

function process(indiv::NEATIndiv, last_features::Array{Float64})
    !sort(indiv.genes, by= g -> g.origin, rev=false)
    for g in indiv.genes

    end
end
