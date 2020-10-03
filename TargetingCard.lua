local CardBase = require "./CardBase"

local __targetcard = {}

function __targetcard:create(id, name_id, type, handler_uuid, target_idx)
    local inst = CardBase:create(id, name_id, type, handler_uuid)
    inst.target_idx = target_idx
    inst.type = type
    return inst
end

return __targetcard