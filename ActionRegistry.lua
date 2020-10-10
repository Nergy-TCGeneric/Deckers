local __registry = {}
local __actions = {}

--[[ 
    Action function MUST have these parameters:
    #1. 'field', a field instance.
    #2. 'target_ctx', a target context. could be a function(with parameter 'field' and 'target_ctx') or a table.
    #3. 'invoker', a user invoked this action.
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
    return __actions[id]
end

return __registry