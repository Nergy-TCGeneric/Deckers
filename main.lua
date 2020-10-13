
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

self.onEnable(function()
    local path_separator = string.sub(os.getenv("PATH"), 1, 1) == "/" and "/" or "\\"
    local directory_map = {cards={CardRegistry, ".json"}, entities={EntityRegistry, ".json"}, actions={ActionRegistry, ".lua"}}
    local path = string.format(".%splugins%sBarmEssentials%sunits%scommander.lkt%s", path_separator, path_separator, path_separator, path_separator, path_separator)
    local command = ""
    for dir, registry in pairs(directory_map) do
        if path_separator == "\\" then
            command = string.format("cmd /c dir %s%s\\*%s /b", path, dir, registry[2])
        elseif path_separator == "/" then
            command = string.format("sh find %s%s -type f -name \"*%s\"", path, dir, registry[2])
        end
        local k = io.popen(command)
        local value = k:read("*l")

        while value ~= nil do
            if registry[2] == ".lua" then
                local code = loadfile(string.format("%s%s%s%s", path, dir, path_separator, value))()
                registry[1].register(code.id, code.act)
            elseif registry[2] == ".json" then
                local f = io.open(string.format("%s%s%s%s", path, dir, path_separator, value))
                if f ~= nil then 
                    registry[1].register(json.decode(f:read("*a"))) 
                    f:close()
                end
            end
            value = k:read("*l")
        end
    end
end)

self.addCommand({name="cmder", permission="co.barm.player"}, function(e)
    local sender = e:getSender()
    sender:sendMessage(colored([[
        &6/cmder start &7<player-name> <player-name> - Starts Commander! session with given players.
        &6/cmder list &7- Lists currently active Commander! session.
        &6/cmder stop &7<session-id> - Stops specified Commander! session.
    ]]))
end)