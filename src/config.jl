export get_config

function get_config(filename::String)
    cfg = YAML.load_file(filename)
    cfg["activation_functions"]=[]

    for k in keys(activ_dict)
        if cfg[k]
            push!(cfg["activation_functions"], activ_dict[k])
        end
        if cfg["hyperNEAT"] && cfg["hn_activation"]==k
            cfg["hn_activ_func"] = activ_dict[k]
        end
    end

    cfg["Species"]=Dict()

    cfg
end
