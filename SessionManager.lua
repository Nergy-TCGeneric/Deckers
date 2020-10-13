local __manager = {}
local __sessions = {}

function __manager.add(field_session)
    assert(field_session, "Invalid field session is given.")
    __sessions[field_session.id] = field_session
end

function __manager.get(id)
    return __sessions[id]
end

function __manager.list()
    local clone = {}
    for k, v in pairs(__sessions) do clone[k] = v end
    return clone
end

function __manager.remove(id)
    assert(id, "Invalid field session id is given.")
    __sessions[id] = nil
end

return __manager