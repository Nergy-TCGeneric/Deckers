package.path = './?.lua;' .. package.path
local tests = require "./tests/Tests"
local json = require "./lib/json"
local EventManager = require "./EventManager"
local EventDeathEventHandler = require "./EntityDeathEventHandler"
local PhaseStartEventHandler = require "./PhaseStartEventHandler"
local GameEndEventHandler = require "./GameEndEventHandler"
local EntityRegistry = require "./EntityRegistry"

EventManager.register(EventDeathEventHandler, "ENTITY_DEATH")
EventManager.register(PhaseStartEventHandler, "PHASE_START")
EventManager.register(GameEndEventHandler, "GAME_END")

local path_discriminator = package.config:sub(1,1)
local command = ""
if path_discriminator == "\\" then
    command = string.format("dir .%scards%s*.json /b", path_discriminator, path_discriminator)
elseif path_discriminator == "/" then
    command = string.format("find .%scards -type f -name \"*.json\"", path_discriminator)
end

for file in io.popen(command):lines() do
    local name = file:gmatch("([^.]+)")()
    local f = io.open(string.format(".%scards%s%s", path_discriminator, path_discriminator, file))
    if f ~= nil then
        EntityRegistry.register(name, json.decode(f:read("*a")))
        f:close()
    end
end

tests.test_all()