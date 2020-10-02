-- Manages registration of cards used on Decker.
local CardType = require "./CardType"

local cards = {}
local _registry = {}

local function is_valid_cardtype(card_type)
    for _, T in ipairs(CardType) do
        if card_type == T then return true end
    end
    return false
end

local function is_valid_card(card)
    if card == nil then return false end
    return card.health > 0
          and is_valid_cardtype(card.type)
          and card.atk_str >= 0
          and card.id ~= nil
          and card.id ~= ""
end

function _registry.register(card)
    assert(is_valid_card(card), "Invalid card is given!")
    cards[card.id] = card
end

function _registry.get(card_id)
    return cards[card_id]
end

function _registry.list()
    clone = {}
    for k, v in pairs(cards) do clone[k] = v end
    return clone
end

return _registry