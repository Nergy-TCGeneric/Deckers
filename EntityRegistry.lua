local __registry = {}
local __entities = {}

--[[
    Entity context format has following these properties:
    1. lifepoint - = Health. If this goes below 0, the entity got terminated.
    2. atk_str = Attack strength. Each turn the entity will try to inflict the damage base on this value.
    3. defense = How much inflicted damage to self will be reduced.
    4. map_id = Mapping identifier. could be anything, such as minecraft:chicken.
]]--

local function is_valid_context_format(entity_ctx)
    return entity_ctx.lifepoint ~= nil
        and entity_ctx.lifepoint > 0
        and entity_ctx.atk_str ~= nil
        and entity_ctx.defense ~= nil
        and entity_ctx.map_id ~= nil
end

function __registry.register(entity_id, entity_ctx)
    assert(entity_ctx and entity_id, "One of given entity parameters are invalid")
    if not is_valid_context_format(entity_ctx) then error("Invalid entity context is given.") end
    __entities[entity_id] = entity_ctx
end

function __registry.get(entity_id)
    local clone = {}
    clone[entity_id] = __entities[entity_id]
    return clone
end

function __registry.list()
    local clone = {}
    for k, v in pairs(__entities) do clone[k] = v end
    return clone
end

return __registry