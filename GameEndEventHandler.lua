local EventHandlerInterface = require "./EventHandlerInterface"
local __handler = EventHandlerInterface:create()

function __handler:update(event)
    print(event.winner)
end

return __handler