export get_config

function get_config(filename::String)
    YAML.load_file(filename)
end
