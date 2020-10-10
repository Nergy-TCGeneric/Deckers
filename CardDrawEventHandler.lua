local __event = require "./EventHandlerInterface":create()

function __event:update(event)
    local cards = event.field.users[event.invoker].available_cards
    for i, v in pairs(cards) do
        if event.card == v then table.remove(cards, i) break end
    end
end

return __event