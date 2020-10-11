local CardType = require "./CardType"
local GenerateUUID = require "./UUIDGenerator"
local EntityCard = require "./EntityCard"
local TargetingCard = require "./TargetingCard"

local __cards = {}
local _registry = {}

--[[
    Card has following these common properties:
    1. id - @Nullable, A card's 'instance' identifier.
    2. type - A card's type. MUST be one of type defined on CardType.lua.
    3. card_id - Different from #1. id, it's an unique identifer for card itself.
]]--

local function is_valid_cardtype(card_type)
    return CardType[card_type:lower()] ~= nil
end

local function is_valid_card(card)
    if card == nil then return false end
    if card.name_id == nil
        or card.name_id == ""
        or not is_valid_cardtype(card.type) then return false end
    if card.type == CardType.mob then
        return card.mob_id ~= nil
    else
        return card.cost_type ~= nil
            and card.cost ~= nil
    end
end

function _registry.register(card)
    assert(is_valid_card(card), "Invalid card is given!")
    local target = nil
    if card.type == "MOB" then
        target = EntityCard:create(
            GenerateUUID(),
            card.name_id,
            card.mob_id
        )
    elseif card.type == CardType.biome or card.type == CardType.equipment or card.type == CardType.magic or card.type == CardType.special then
        target = TargetingCard:create(
            GenerateUUID(),
            card.name_id,
            card.type,
            card.cost_type,
            card.cost,
            card.action_id
        ) 
    else
        error("Invalid type is given.")
    end
    __cards[card.name_id] = target
end

function _registry.unregister_all()
    __cards = {}
end

function _registry.get(card_id)
    assert(card_id, "Card id is invalid!")
    if __cards[card_id] == nil then return nil end
    local clone = {}
    for k, v in pairs(__cards[card_id]) do clone[k] = v end
    clone.id = GenerateUUID()
    return clone
end

function _registry.list()
    local clone = {}
    for k, v in pairs(__cards) do clone[k] = v end
    return clone
end

return _registry