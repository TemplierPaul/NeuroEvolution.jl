export load_gen, NEATIndiv

"""
Function to load an entire population from a gen folder.
The evolution need to be initialized first.
"""
function load_gen(e::Evolution, path::String)
	individualNameList = readdir("gens/$path")
	individualList = Cambrian.Individual[]
	for i in eachindex(individualNameList)
		indString = read("gens/$path/$(individualNameList[i])", String)
		ind = NEATIndiv(cfg,indString)
		push!(individualList,ind)
	end
	e.population = individualList
end

function NEATIndiv(cfg::Dict, ind::String)
	dict = JSON.parse(ind)
	print(dict)
end
