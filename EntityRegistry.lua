local __registry = {}
local __entities = {}

--[[
    Entity context format has following these properties:
    1. lifepoint - = Health. If this goes below 0, the entity got terminated.
    2. atk_str = Attack strength. Each turn the entity will try to inflict the damage base on this value.
    3. defense = How much inflicted damage to self will be reduced.
    4. map_id = Mapping identifier. could be anything, such as minecraft:chicken.
    5. behavior = Decides how this mob will behave during battle. Must be one of these : (Passive, Neutral, Hostile)
    6. size = determines how much this mob will occupy adjacent tiles. 2 means it occupies 2 * 2 tiles.
    7. atk_range = Attack range. By each tick, this entity will try to attack opponent entity within this range.
    8. entity_id = An unique identifier for entity itself. used for entity registration.
]]--

local function is_valid_context_format(entity_ctx)
    return entity_ctx.lifepoint > 0
        and entity_ctx.atk_str ~= nil
        and entity_ctx.defense ~= nil
        and entity_ctx.map_id ~= nil
        and (entity_ctx.behavior == "PASSIVE" or entity_ctx.behavior == "NEUTRAL" or entity_ctx.behavior == "HOSTILE")
        and entity_ctx.size >= 1
        and entity_ctx.atk_range >= 1
        and entity_ctx.move_range >= 1
        and entity_ctx.entity_id ~= nil
end

function __registry.register(entity_ctx)
    assert(entity_ctx, "Invalid entity context is given.")
    if not is_valid_context_format(entity_ctx) then error("Invalid entity context is given.") end
    __entities[entity_ctx.entity_id] = entity_ctx
end

function __registry.unregister(entity_id)
    __entities[entity_id] = nil
end

function __registry.unregister_all()
    __entities = {}
end

function __registry.get(entity_id)
    assert(entity_id, "Invalid entity id is given.")
    local entity = __entities[entity_id]
    if entity == nil then return nil end
    local clone = {}
    for k, v in pairs(entity) do clone[k] = v end
    return clone
end

function __registry.list()
    local clone = {}
    for k, v in pairs(__entities) do clone[k] = v end
    return clone
end

return __registry