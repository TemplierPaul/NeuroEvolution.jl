export save_gen, load_gen!, string

## NEATIndiv to JSON
function get_name(func)
    for (name, f) in pairs(activ_dict)
        if f == func
            return name
        end
    end
end

function get_name(dict::Dict)
    new_dict = Dict()
    for (k, v) in pairs(dict)
        new_dict[k]=get_name(v)
    end
    new_dict
end

function fitness_value(f::Float64)
	if f == -Inf
		"-Inf"
	end
	string(f)
end

function Base.string(indiv::NEATIndividual)
    d = Dict(
	"Type"=>"NEAT",
    "Genes"=>indiv.genes,
    "Fitness"=>fitness_value.(indiv.fitness),
    "Activ_func"=>get_name(indiv.activ_functions)
    )
    JSON.json(d)
end

function Base.string(indiv::HyperNEATIndividual)
    d = Dict(
	"Type"=>"HyperNEAT",
    "Genes"=>indiv.genes,
    "Fitness"=>indiv.fitness,
    "Activ_func"=>get_name(indiv.activ_functions)
    )
    JSON.json(d)
end

## Load
"""
Function to load an entire population from a gen folder.
The evolution need to be initialized first.
"""
function load_gen!(e::Evolution, path::String)
	individualNameList = readdir("gens/$path")
	individualList::Array{NEATIndiv} = []
	for i in eachindex(individualNameList)
		indString = read("gens/$path/$(individualNameList[i])", String)
		ind = NEATIndiv(e.cfg, indString)
		build!(ind)
		push!(individualList,ind)
	end
	e.population = individualList
end
