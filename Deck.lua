-- A 'deck' is a list of cards which separated by its usage.
local CardType = require "./CardType"
local _deck = {}

function _deck:create()
    local inst = setmetatable({}, _deck)
    inst.__index = self
    for _, T in ipairs(CardType) do inst[T] = {} end
    return inst
end

function _deck:put(card)
    assert(card, "Card cannot be nil")
    _deck[card.type]:insert(card)
end

function _deck:remove(card)
    assert(card, "Card cannot be nil")
    _deck[card.type]:remove(card)
end

return _deck