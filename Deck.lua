-- A 'deck' is a list of cards which separated by its usage.
local CardType = require "./CardType"
local __deck = {}

function __deck:create()
    local inst = setmetatable({}, __deck)
    inst.__index = self
    for _, T in ipairs(CardType) do inst[T] = {} end
    return inst
end

function __deck:put(card)
    assert(card, "Card cannot be nil")
    __deck[card.type]:insert(card)
end

function __deck:remove(idx)
    assert(idx and idx > 0, "Index cannot be nil or negative")
    __deck[card.type]:remove(idx)
end

function __deck:range_from(point, dist, type)
    if point < 1 or point > #__deck[card.type] then error(string.format("Invalid point is given : %s", point)) end
    local low, high = math.max(point - dist, 1), math.min(point + dist, #__deck[card.type])
    local range = {}
    for i=low,high do range.insert(i) end
    return range
end

return __deck