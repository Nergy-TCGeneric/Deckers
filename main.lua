package.path = './?.lua;' .. package.path
local tests = require "./tests/Tests"
local json = require "./lib/json"
local EventManager = require "./EventManager"
local EventDeathEventHandler = require "./EntityDeathEventHandler"
local PhaseStartEventHandler = require "./PhaseStartEventHandler"
local GameEndEventHandler = require "./GameEndEventHandler"
local CardDrawEventHandler = require "./CardDrawEventHandler"
local EntityRegistry = require "./EntityRegistry"
local ActionRegistry = require "./ActionRegistry"
local CardRegistry = require "./CardRegistry"

tests.test_all()
EventManager.register(EventDeathEventHandler, "ENTITY_DEATH")
EventManager.register(PhaseStartEventHandler, "PHASE_START")
EventManager.register(GameEndEventHandler, "GAME_END")
EventManager.register(CardDrawEventHandler, "CARD_DRAW")

local path_discriminator = package.config:sub(1,1)
local directory_map = {cards={CardRegistry, ".json"}, entities={EntityRegistry, ".json"}, actions={ActionRegistry, ".lua"}}
local command = ""
for dir, registry in pairs(directory_map) do
    if path_discriminator == "\\" then
        command = string.format("dir .%s%s%s*%s /b", path_discriminator, dir, path_discriminator, registry[2])
    elseif path_discriminator == "/" then
        command = string.format("find .%s%s -type f -name \"*%s\"", path_discriminator, dir, registry[2])
    end

    for file in io.popen(command):lines() do
        local f = io.open(string.format(".%s%s%s%s", path_discriminator, dir, path_discriminator, file))
        if f ~= nil then
            if registry[2] == ".json" then
                registry[1].register(json.decode(f:read("*a")))
            elseif registry[2] == ".lua" then
                local code = loadstring(f:read("*a"))()
                registry[1].register(code.id, code.act)
            end
            f:close()
        end
    end
end