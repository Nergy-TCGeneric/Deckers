package.path = './?.lua;' .. package.path
local tests = require "./tests/Tests"
local json = require "./lib/json"
local EventManager = require "./EventManager"
local EventDeathEventHandler = require "./EntityDeathEventHandler"
local PhaseStartEventHandler = require "./PhaseStartEventHandler"
local GameEndEventHandler = require "./GameEndEventHandler"
local EntityRegistry = require "./EntityRegistry"
local ActionRegistry = require "./ActionRegistry"
local CardRegistry = require "./CardRegistry"

tests.test_all()
EventManager.register(EventDeathEventHandler, "ENTITY_DEATH")
EventManager.register(PhaseStartEventHandler, "PHASE_START")
EventManager.register(GameEndEventHandler, "GAME_END")

local path_discriminator = package.config:sub(1,1)
local directory_map = {cards=CardRegistry, entities=EntityRegistry}
local command = ""
for dir, registry in pairs(directory_map) do
    if path_discriminator == "\\" then
        command = string.format("dir .%s%s%s*.json /b", path_discriminator, dir, path_discriminator)
    elseif path_discriminator == "/" then
        command = string.format("find .%s%s -type f -name \"*.json\"", path_discriminator, dir)
    end

    for file in io.popen(command):lines() do
        -- local name = file:gmatch("([^.]+)")()
        local f = io.open(string.format(".%s%s%s%s", path_discriminator, dir, path_discriminator, file))
        if f ~= nil then
            registry.register(json.decode(f:read("*a")))
            f:close()
        end
    end
end

-- TODO: Load .lua files from ./actions