-- A 'deck' is a list of cards which separated by its usage.
local __deck = {}

function __deck:create()
    local inst = setmetatable({}, self)
    self.__index = self
    inst.__cards = {}
    return inst
end

function __deck:put(card) -- Only accepts MOB type cards.
    assert(card, "Card cannot be nil")
    assert(card.type == "MOB", "Deck only accepts MOB type cards.")
    table.insert(self.__cards, card)
end

function __deck:remove(idx)
    assert(idx and idx > 0, "Index cannot be nil or less than 0")
    table.remove(self.__cards, card)
end

function __deck:get(idx)
    return self.__cards[idx]
end

function __deck:size()
    return #self.__cards
end

function __deck:range_from(point, dist)
    if point < 1 or point > #self.__cards then error(string.format("Invalid point is given : %s", point)) end
    local low, high = math.max(point - dist, 1), math.min(point + dist, #self.__cards)
    local range = {}
    for i=low,high do table.insert(range, i) end
    return range
end

return __deck