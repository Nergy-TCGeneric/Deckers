local __stack = {}

local function is_valid_type(v)
    return v.id ~= nil and v.id ~= "" and v.type ~= nil
end

function __stack:create()
    local inst = setmetatable({}, self)
    self.__index = self
    inst.__entries = {}
    return inst
end

function __stack:push(v)
    if not is_valid_type(v) then error("Only card type is acceptable") end
    if #self.__entries >= 10 then self.__entries:remove(1) end
    self.__entries:insert(v)
end

function __stack:pop()
    self.__entries:remove()
end

function __stack:clear()
    self.__entries = {}
end

return __stack