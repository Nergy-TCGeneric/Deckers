-- Field test
local Field = require "./Field"
local EntityCard = require "./EntityCard"
local EntityRegistry = require "./EntityRegistry"

local _test = {}

-- Test #1: Creating and retrieving Field instance
local function func1()
    local f = Field:create_instance({uuid = "fake_uuid_1", selected_deck = {}}, {uuid = "fake_uuid_2", selected_deck = {}})
    assert(f.first_user.uuid == "fake_uuid_1"
        and f.second_user.uuid == "fake_uuid_2"
        and f.phase == 0,
        "Test #1 failed"
    )
end

-- Test #2: Putting some fake cards and proceeding turn
local function func2()
    EntityRegistry.register("spider", { lifepoint=15, atk_str=2, defense=0, map_id="minecraft:spider"} )
    local f = Field:create_instance({uuid = "fake_uuid_1", selected_deck = {}}, {uuid = "fake_uuid_2", selected_deck = {}})
    f:spawn_entity("fake_uuid_1", EntityCard:create("some_uuid4_format", "fake_one", "fake_uuid_1", "spider"))
    f:spawn_entity("fake_uuid_2", EntityCard:create("other_uuid4_format", "fake_two", "fake_uuid_2", "spider"))
    f:proceed_turn()
    local base_entity = EntityRegistry.get("spider")
    assert(base_entity.lifepoint - f.first_deck:get(1).mob.lifepoint == base_entity.atk_str - base_entity.defense
        and base_entity.lifepoint - f.second_deck:get(1).mob.lifepoint == base_entity.atk_str - base_entity.defense,
        "Test #2 failed")
end

-- Test #3: Isloation test
local function func3()
    local f1 = Field:create_instance({uuid = "fake_uuid_1", selected_deck={}}, {uuid = "fake_uuid_2", selected_deck={}})
    local f2 = Field:create_instance({uuid = "fake_uuid_3", selected_deck={}}, {uuid = "fake_uuid_4", selected_deck={}})
    assert(f1 ~= f2
        and f1.first_user.uuid == "fake_uuid_1"
        and f1.second_user.uuid == "fake_uuid_2"
        and f2.first_user.uuid == "fake_uuid_3"
        and f2.second_user.uuid == "fake_uuid_4", "Test #3 failed")
end

-- Test #4: Overkill test. No assertion
local function func4()
    local f1 = Field:create_instance({uuid = "fake_uuid_1", selected_deck = {}}, {uuid = "fake_uuid_2", selected_deck = {}})
    EntityRegistry.register("killer", { lifepoint=25, atk_str=20, defense=0, map_id="undefined"})
    f1:spawn_entity("fake_uuid_1", EntityCard:create("some_uuid4_format", "fake_one", "fake_uuid_1", "killer"))
    f1:spawn_entity("fake_uuid_2", EntityCard:create("other_uuid4_format", "fake_two", "fake_uuid_2", "spider"))
    f1:proceed_turn()
end

function _test.test_all()
    func1()
    func2()
    func3()
    func4()
    EntityRegistry.unregister("spider")
    EntityRegistry.unregister("killer")
    print("Passed all Field tests")
end

return _test