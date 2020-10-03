local CardBase = require "./CardBase"
local EntityRegistry = require "./EntityRegistry"

local __entcard = {}

function __entcard:create(id, name_id, handler_uuid, mob_id)
    local inst = CardBase:create(id, name_id, handler_uuid)
    inst.type = "MOB"
    inst.mob = EntityRegistry.get(mob_id)
    return inst
end

return __entcard