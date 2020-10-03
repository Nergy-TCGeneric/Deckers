-- Field test
local Field = require "./Field"
local CardType = require "./CardType"
local EntityCard = require "./EntityCard"
local EntityRegistry = require "./EntityRegistry"

local _test = {}

local function contains_cardtypes(deck)
    for _, T in ipairs(CardType) do
        if deck[T] == nil then return false end
    end
    return true
end

-- Test #1: Creating and retrieving Field instance
local function func1()
    local f = Field:create_instance({uuid = "fake_uuid_1", selected_deck = {}}, {uuid = "fake_uuid_2", selected_deck = {}})
    assert(f.first_user.uuid == "fake_uuid_1"
        and f.second_user.uuid == "fake_uuid_2"
        and f.phase == 0
        and contains_cardtypes(f.first_deck)
        and contains_cardtypes(f.second_deck),
        "Test #1 failed"
    )
end

-- Test #2: Putting some fake cards and proceeding turn
local function func2()
    EntityRegistry.register("spider", { lifepoint=15, atk_str=2, defense=0, map_id="minecraft:spider"} )
    local f = Field:create_instance({uuid = "fake_uuid_1", selected_deck = {}}, {uuid = "fake_uuid_2", selected_deck = {}})
    for k, v in pairs(f) do print(k, v) end
    f:put_card("fake_uuid_1", EntityCard:create("some_uuid4_format", "fake_one", "fake_uuid_1", "spider"))
    f:put_card("fake_uuid_2", EntityCard:create("other_uuid4_format", "fake_two", "fake_uuid_2", "spider"))
    f:proceed_turn()
    local base_entity = EntityRegistry.get("spider")
    assert(base_entity.lifepoint - f.first_deck["MOB"][1].lifepoint == base_entity.atk_str - base_entity.defense
        and base_entity.lifepoint - f.second_deck["MOB"][1].lifepoint == base_entity.atk_str - base_entity.defense,
        "Test #2 failed")
end

function _test.test_all()
    func1()
    func2()
    print("Passed all Field tests")
end

return _test