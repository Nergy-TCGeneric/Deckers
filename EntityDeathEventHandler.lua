local EventHandlerInterface = require "./EventHandlerInterface"
local __handler = EventHandlerInterface:create()

function __handler:update(event)
    assert(event, "Event cannot be null")
    print(event.killer.handler_uuid, event.dead.handler_uuid)
end

return __handler