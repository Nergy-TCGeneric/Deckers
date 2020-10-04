-- Manages registration of __cards used on Decker.
local CardType = require "./CardType"

local __cards = {}
local _registry = {}

--[[
    Card has following these common properties:
    1. id - A card's identifier.
    2. type - A card's type. MUST be one of type defined on CardType.lua.
]]--

local function is_valid_cardtype(card_type)
    for _, T in ipairs(CardType) do
        if card_type == T then return true end
    end
    return false
end

local function is_valid_card(card)
    if card == nil then return false end
    return card.id ~= nil
        and card.id ~= ""
        and is_valid_cardtype(card.type)
end

function _registry.register(card)
    assert(is_valid_card(card), "Invalid card is given!")
    __cards[card.id] = card
end

function _registry.get(card_id)
    assert(card_id, "Card id is invalid!")
    if __cards[card_id] == nil then return nil end
    local clone = {}
    for k, v in pairs(__cards[card_id]) do clone[k] = v end
    return clone
end

function _registry.list()
    local clone = {}
    for k, v in pairs(__cards) do clone[k] = v end
    return clone
end

return _registry