local __IEventHandler = {}

function __IEventHandler:create()
    local inst = setmetatable({}, self)
    self.__index = self
    return inst
end

function __IEventHandler:update(event)
    error("Override this function")
end

return __IEventHandler