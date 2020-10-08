local __tiles= {}

-- Starting from index 1, at left-bottom corner.
--[[
    TileData has following properties:
    1. size - Determines tile's maximum horizontal and vertical length limit.
    2. tile - A list of entities' position and entity data.
    -> A tile has no obstacles. it only consists of bunch of user's mobs.
    3. entities - For fast indexing. shows which player has which entities.
]]

local function get_occupying_area(loc, size)
    assert(size > 0, "Size cannot be less than 0")
    return {loc, {x = loc.x + (size-1), y = loc.y + (size-1)}}
end

function __tiles:create(size)
    local inst = setmetatable({}, self)
    self.__index = self
    inst.tile = {}
    inst.entities = {}
    inst.size = size
    return inst
end

function __tiles:get_entity_location(entity)
    for idx, tile in pairs(self.tile) do
        if tile.entity == entity then return tile.loc end
    end
    return nil
end

function __tiles:spawn_entity(entity, loc)
    local occupied = get_occupying_area(loc, entity.size)
    if occupied[2].x > self.size or occupied[2].y + entity.size > self.size or loc.x < 1 or loc.y < 1 or loc.x > self.size or loc.y > self.size then return false end
    table.insert(self.tile, {
        loc = loc,
        entity = entity
    })
    if self.entities[entity.handler_uuid] == nil then self.entities[entity.handler_uuid] = {} end
    table.insert(self.entities[entity.handler_uuid], entity)
    return true
end

function __tiles:remove_entity(entity)
    local loc = self:get_entity_location(entity)
    for idx, tile in pairs(self.tile) do
        if tile.entity == entity then
            table.remove(self.tile, idx)
            for i, v in ipairs(self.entities[entity.handler_uuid]) do
                if v == entity then table.remove(self.entities[entity.handler_uuid], i) break end
            end
            return true
        end
    end
    return false
end

function __tiles:move_to(entity, loc)
    if self:is_occupied(loc) and not self:is_entity_movable_to(loc, entity) then return false end
    for idx, tile in pairs(self.tile) do
        if tile.entity == entity then
            self.tile[idx] = {
                loc = loc,
                entity = entity
            }
            return true
        end
    end
    error("Given entity isn't on tile. Did you forgot using move_to?")
end

function __tiles:distance(from, to)
    assert(from and to, "Given location type is not valid")
    return math.abs(to.x - from.x) + math.abs(to.y - from.y)
end

function __tiles:move_to_relatively(entity, diff)
    local loc = self:get_entity_location(entity)
    assert(loc and diff, "Invalid entity or difference is given.")
    if self:is_occupied(loc) and not self:is_entity_movable_to(loc, entity) then return false end
    for idx, tile in pairs(self.tile) do
        if tile.entity == entity then
            self.tile[idx] = {
                loc = { x = loc.x + diff.x, y = loc.y + diff.y},
                entity = entity
            }
            return true
        end
    end
    error("Given entity isn't on tile. Did you forgot using move_to?")
end

function __tiles:is_occupied(loc)
    for _, tile in pairs(self.tile) do
        if (tile.loc.x == loc.x and tile.loc.y == loc.y)
            or (tile.loc.x <= loc.x and tile.loc.x + tile.entity.size >= loc.x and tile.loc.y <= loc.y and tile.loc.y + tile.entity.size >= loc.y) then
            return true end
    end
    return false
end

function __tiles:is_entity_movable_to(loc, entity)
    assert(loc and entity, "Given location or entity is nil")
    return loc.x > 0 
        and loc.x <= self.size
        and loc.y > 0
        and loc.y <= self.size
        and loc.x + entity.size <= self.size
        and loc.y + entity.size <= self.size 
end

function __tiles:clear()
    self.entities = {}
    self.tile = {}
end

function __tiles:list()
    return self.tile
end

function __tiles:get_entities()
    return self.entities
end

function __tiles:has_no_entities()
    for _, v in pairs(self.entities) do
        if #v == 0 then return true end
    end
    return false
end

return __tiles