local _stack = {}

local function is_valid_type(v)
    return v.id ~= nil and v.id ~= "" and v.type ~= nil
end

function _stack:create()
    local inst = setmetatable({}, _stack)
    inst.__index = self
    inst.__entries = {}
    return inst
end

function _stack:push(v)
    if not is_valid_type(v) then error("Only card type is acceptable") end
    if #self.__entries >= 10 then self.__entries:remove(1) end
    self.__entries:insert(v)
end

function _stack:pop()
    self.__entries:remove()
end

return _stack