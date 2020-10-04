local EventHandlerInterface = require "./EventHandlerInterface"
local __handler = EventHandlerInterface:create()

function __handler:update(event)
    print(event.phase)
end

return __handler