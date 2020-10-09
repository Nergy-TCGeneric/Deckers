local EventHandlerInterface = require "./EventHandlerInterface"
local __handler = EventHandlerInterface:create()

function __handler:update(event)
    print(event.lose)
end

return __handler