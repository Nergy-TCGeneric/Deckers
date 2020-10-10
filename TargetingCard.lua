local CardBase = require "./CardBase"
local ActionRegistry = require "./ActionRegistry"

local __targetcard = {}

--[[
    Targeting Card has following distinctive properties:
    1. act(function) : Determines what this card do on field.
    2. cost : Determines the 'cost' when this card draw.
    3. cost_type : Determines 'cost type'. MUST be one of these : (Mana / Action)
    4. action_id : An action id to get 'action' from ActionRegistry.
]]

function __targetcard:create(id, name_id, type, cost_type, cost, action_id)
    local inst = CardBase:create(id, name_id, type)
    inst.type = type
    inst.cost_type = cost_type
    inst.cost = cost
    inst.act = ActionRegistry.get(action_id) or function(field, target_ctx, invoker) end
    return inst
end

return __targetcard