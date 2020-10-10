local __card = {}

--[[
    Cardbase has following properties:
    1. id - A 'unique' identifier. used when searching cards.
    2. type - A card's type. MUST be one of type defined on CardType.lua
    3. name_id - used when mapping name from cardname.json by using this id.
]]

function __card:create(id, name_id)
    local inst = setmetatable({}, __card)
    inst.__index = self
    inst.id = id
    inst.name_id = name_id
    return inst
end

function __card:act(field_inst)
    error("One of the card instance didn't overridden this function.")
end

return __card