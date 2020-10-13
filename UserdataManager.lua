local __manager = {}
local cache = setmetatable({}, {__mode="kv"})
local json = require "./lib/json"

local function is_valid_userdata(user_data) 
    return user_data.uuid ~= nil
    and type(user_data.available_deck) == "table"
end 

function __manager.deserialize(uuid)
    assert(type(uuid)=="string", "Given uuid must be a string type.")
    if cache[uuid] then return cache[uuid] end
    -- TODO: Assuming the user uses 'windows'. Create a related function to get a file properly.
    local f = io.open(string.format("./plugins/BarmEssentials/units/commander.lkt/users/%s.json", uuid))
    local status, retval = pcall(function()
        local data = json.decode(f:read("*a"))
        return data
    end)
    f:close()
    if status then
        cache[uuid] = retval
        return retval
    else return nil end
end

function __manager.serialize(user_data)
    assert(user_data, "Given user data must not be null")
    assert(is_valid_userdata(user_data), "Not a valid user data")
    local f = io.open(string.format("./plugins/BarmEssentials/units/commander.lkt/users/%s.json", user_data.uuid), "w+")
    local status, retval = pcall(function()
        data = json.encode(user_data)
        return data
    end)
    if status then f:write(data) end
    f:close()
end

return __manager