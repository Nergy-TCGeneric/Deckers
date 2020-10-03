local __card = {}

--[[
    Cardbase has following properties:
    1. id - A 'unique' identifier. used when searching cards.
    2. type - A card's type. MUST be one of type defined on CardType.lua
    3. handler_uuid - @Nullable. if it's not nil, this indicates who just drawed this card.
    4. name_id - used when mapping name from cardname.json by using this id.
]]

function __card:create(id, name_id, handler_uuid)
    local inst = setmetatable({}, __card)
    inst.__index = self
    inst.id = id
    inst.name_id = name_id
    inst.handler_uuid = handler_uuid
    return inst
end

function __card:act(field_inst)
    error("One of the card instance didn't overridden this function.")
end

return __card