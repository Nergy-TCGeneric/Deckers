local __registry = {}
local __actions = {}

--[[ 
    Action function MUST have these parameters:
    #1. 'field', a field instance.
    #2. 'target_ctx', a target context. could be a function(with parameter 'field' and 'target_ctx') or a table.
]]

function __registry.register(id, act_func)
    assert(type(act_func) == "function", "Given Action function is not a function.")
    __actions[id] = act_func
end

function __registry.unregister(id)
    __actions[id] = nil
end

function __registry.unregister_all()
    __actions = {}
end

function __registry.get(id)
    if __actions[id] == nil then return nil end
    local clone = {}
    for k, v in pairs(__actions[id]) do clone[k] = v end
    return clone
end

return __registry