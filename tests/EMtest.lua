local EventManager = require "./EventManager"
local IEventHandler = require "./EventHandlerInterface"

local _test = {}

-- Test #1. Isolation test
local function func1()
    local h1, h2 = IEventHandler:create(), IEventHandler:create()
    assert(h1 ~= h2, "#1. h1 and h2 MUST not be an identical object")
    h1.update = function() end
    h2.update = function() end
    EventManager.register(h1, "TYPE_1")
    EventManager.register(h2, "TYPE_2")
    assert(EventManager.get_handlers("TYPE_1")[1] == h1 and
        EventManager.get_handlers("TYPE_2")[1] == h2
    , "#2. Registered event handler and actual event handler doesn't match")
end

function _test.test_all()
    func1()
    EventManager.unregister_all()
    print("Passed all EventManager tests")
end

return _test