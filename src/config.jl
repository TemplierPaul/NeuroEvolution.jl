export get_config

function get_config(filename::String)
    cfg = YAML.load_file(filename)

    cfg["activation_functions"]=[]

    if cfg["sigmoid"]
        push!(cfg["activation_functions"], sigmoid)
    end
    if cfg["ReLU"]
        push!(cfg["activation_functions"], ReLU)
    end
    if cfg["sin"]
        push!(cfg["activation_functions"], sin)
    end
    if cfg["cos"]
        push!(cfg["activation_functions"], cos)
    end
    if cfg["tanh"]
        push!(cfg["activation_functions"], tanh_activ)
    end
    if cfg["abs"]
        push!(cfg["activation_functions"], abs)
    end
    if cfg["identity"]
        push!(cfg["activation_functions"], identity_activ)
    end
    if cfg["gauss"]
        push!(cfg["activation_functions"], gauss)
    end

    cfg
end
