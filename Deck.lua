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
    if self.__cards[card.handler_uuid] == nil then self.__cards[card.handler_uuid] = {} end
    table.insert(self.__cards[card.handler_uuid], card)
end

function __deck:remove(uuid, idx)
    assert(idx and idx > 0, "Index cannot be nil or less than 0")
    table.remove(self.__cards[uuid], idx)
end

function __deck:remove_by_card(card)
    for i, c in ipairs(self.__cards[card.handler_uuid]) do
        if c == card then self:remove(card.handler_uuid, i) break end
    end
end

function __deck:get_by_index(uuid, idx)
    return self.__cards[uuid][idx]
end

function __deck:get_by_entity(entity)
    for _, cards in pairs(self.__cards) do
        for __, card in ipairs(cards) do
            if card.mob == entity then return card end
        end
    end
    return nil
end

function __deck:size(uuid)
    return #self.__cards[uuid]
end

function __deck:clear()
    self.__cards = {}
end

function __deck:get_empty_deck_owner()
    for uuid, deck in pairs(self.__cards) do
        if #deck == 0 then return uuid end
    end
    return nil
end

function __deck:get_opponent_deck(uuid)
    for id, deck in pairs(self.__cards) do
        if id ~= uuid then return deck end
    end
end

function __deck:get_decks()
    return self.__cards
end

return __deck