-- Field test
local Field = require "./Field"
local CardType = require "./CardType"

local _test = {}

local function contains_cardtypes(deck)
    for _, T in ipairs(CardType) do
        if deck[T] == nil then return false end
    end
    return true
end

-- Test #1: Creating and retrieving Field instance
local function func1()
    f = Field:create_instance({uuid = "fake_uuid_1", selected_deck = {}}, {uuid = "fake_uuid_2", selected_deck = {}})
    assert(f.first_user.uuid == "fake_uuid_1"
        and f.second_user.uuid == "fake_uuid_2"
        and f.phase == 0
        and contains_cardtypes(f.first_deck)
        and contains_cardtypes(f.second_deck),
        "Test #1 failed"
    )
end

function _test.test_all()
    func1()
    print("Passed all Field tests")
end

return _test