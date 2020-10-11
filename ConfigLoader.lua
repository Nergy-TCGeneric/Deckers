local __loader = {}
local __config = {}

local yaml = require "./lib/tinyyaml"

function __loader.load(path)
    assert(path, "A path cannot be nil")
    local f = io.open(path)
    if f == nil then return end
    __config = yaml.parse(f:read("*a"))
    f:close()
end

-- Configuration can be nested.
function __loader.get(key)
    assert(key, "Key cannot be nil")
    assert(__config[key], "Config value is nil")
    return __config[key]
end

function __loader.clear()
    __config = {}
end

return __loader