local __manager = {}

local __handlers = {}

function __manager.register(handler, type)
    assert(handler, "Invalid event handler is given!")
    assert(type, "Type MUST be provided.")
    if __handlers[type] == nil then __handlers[type] = {} end
    table.insert(__handlers[type], handler)
end

function __manager.unregister(handler, type)
    assert(handler, "Invalid event handler is given!")
    assert(type, "Type MUST be provided.")
    if __handlers[type] == nil then return end
    for i, v in ipairs(__handlers[type]) do
        if v == handler then __handlers:remove(i) end
    end
end

function __manager.unregister_all()
    __handlers = {}
end

function __manager.get_handlers(type)
    return __handlers[type]
end

function __manager.notify(event, type)
    assert(event and type, "Invalid event data is given. failed to propagate the event.")
    if __handlers[type] == nil then return end
    for _, handler in ipairs(__handlers[type]) do
        handler:update(event)
    end
end

return __manager