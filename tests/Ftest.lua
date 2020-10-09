-- Field test
local Field = require "./Field"
local EntityCard = require "./EntityCard"
local EntityRegistry = require "./EntityRegistry"
local EventHandlerInterface = require "./EventHandlerInterface"
local EventManager = require "./EventManager"

local _test = {}

-- Test #1: Creating and retrieving Field instance
local function func1()
    local f = Field:create_instance({uuid = "fake_uuid_1", selected_deck = {}}, {uuid = "fake_uuid_2", selected_deck = {}})
    assert(f.users["fake_uuid_1"] and f.users["fake_uuid_2"], "#1. Failed to store userdata properly")
    assert(f.phase == 0, "#2. Failed to set default value while creating field instance")
end

-- Test #2: Isloation test
local function func2()
    local f1 = Field:create_instance({uuid = "fake_uuid_1", selected_deck={}}, {uuid = "fake_uuid_2", selected_deck={}})
    local f2 = Field:create_instance({uuid = "fake_uuid_3", selected_deck={}}, {uuid = "fake_uuid_4", selected_deck={}})
    assert(f1 ~= f2, "#1. Two fields are MUST NOT be identical")
    assert(f1.users["fake_uuid_1"] and f1.users["fake_uuid_2"], "#2. Fields are not isolated")
    assert(f2.users["fake_uuid_3"] and f2.users["fake_uuid_4"], "#3. Fields are not isolated")
end

-- Test #3: Putting some fake cards and proceeding turn. Does death event invoked with expected data?
local function func3()
    local f1 = Field:create_instance({uuid = "fake_uuid_1", selected_deck = {}}, {uuid = "fake_uuid_2", selected_deck = {}})
    EntityRegistry.register({
        lifepoint = 15,
        atk_str = 2,
        defense = 0,
        map_id = "minecraft:spider",
        behavior = "NEUTRAL",
        size = 1,
        atk_range = 1,
        move_range = 1,
        entity_id = "entity:spider"
    })
    EntityRegistry.register({
        lifepoint = 25,
        atk_str = 20,
        defense = 0,
        map_id = "undefined",
        behavior = "HOSTILE",
        size = 1,
        atk_range = 1,
        move_range = 1,
        entity_id = "entity:killer"
    })
    f1:spawn_entity(EntityCard:create("some_uuid4_format", "fake_one", "fake_uuid_1", "entity:killer"), {x = 1, y = 1})
    f1:spawn_entity(EntityCard:create("other_uuid4_format", "fake_two", "fake_uuid_2", "entity:spider"), {x = 7, y = 7})

    local test_handler = EventHandlerInterface:create()
    test_handler.update = function(self, event)
        assert(event and type(event) == "table", "#4. Entity death event didn't propagated properly")
        assert(event.killer.handler_uuid == "fake_uuid_1"
            and event.victim.handler_uuid == "fake_uuid_2", "#4-1. Handler's uuid doesn't match")
        -- Assuming the victim failed to retaliate
        assert(event.killer.lifepoint == 25
            and event.victim.lifepoint == -5, "#4-2. Expected lifepoint and actual lifepoint doesn't match")
        assert(event.victim.behavior == "HOSTILE", "#4-3. Expected behavior and actual behavior doesn't match")
    end
    EventManager.register(test_handler, "ENTITY_DEATH")
    f1:proceed_turn()
end

function _test.test_all()
    func1()
    func2()
    func3()
    EntityRegistry.unregister_all()
    EventManager.unregister_all()
    print("Passed all Field tests")
end

return _test