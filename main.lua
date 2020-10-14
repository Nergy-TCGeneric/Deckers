
local Bukkit = import "$Bukkit"
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
local SessionManager = require "./SessionManager"
local UserdataManager = require "./UserdataManager"
local Field = require "./Field"

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
    local args = e:getArgs()

    if args[1] == nil then
        sender:sendMessage(colored([[
        &6/cmder start &7<player-name> <player-name> - Starts Commander! session with given players.
        &6/cmder list &7- Lists currently active Commander! session.
        &6/cmder stop &7<session-id> - Stops specified Commander! session.
        ]]))
    elseif args[1] == "start" then
        if not (args[2] and args[3]) then sender:sendMessage(colored("&cYou must provide valid player nicknames.")) return end
        local p1, p2 = Bukkit.getServer().getPlayer(args[2]), Bukkit.getServer().getPlayer(args[3])
        if not (p1 and p2) then sender:sendMessage(colored("&cCannot find the player with given nickname!")) return end
        if p1.getUniqueId() ~= sender:getUniqueId() and not sender:hasPermission("co.barm.admin") then sender:sendMessage(colored("&cCannot start the session. The first player MUST be you.")) return end
        local ud1, ud2 = UserdataManager.deserialize(p1:getUniqueId()), UserdataManager.deserialize(p2:getUniqueId())
        if not (ud1 and ud2) then sender:sendMessage(colored("&cUnknown exception raised; contact to administrator.")) return end
        SessionManager.add(Field:create_instance(ud1, ud2))
        sender:sendMessage(colored("&aA new Commander! session is now active, Have fun!"))
    elseif args[1] == "list" then
        if SessionManager.size() == 0 then sender:sendMessage(colored("&7Currently, there's no &cactive &7Commander! session.")) return end
        sender:sendMessage(colored("&7Currently active Commander! sessions :"))
        for k, v in pairs(SessionManager.list()) do
            sender:sendMessage(colored("&7#session &6"..k))
        end
    elseif args[1] == "stop" then
        if args[2] == nil then sender:sendMessage(colored("&cYou must provide a valid Commander! session id.")) return end
        if SessionManager.get(args[2]) == nil then sender:sendMessage(colored("&cNo Commander! session presents with given id.")) return end
        SessionManager.remove(args[2])
        sender:sendMessage(colored("&aSuccessfully stopped the session."))
    end
end)