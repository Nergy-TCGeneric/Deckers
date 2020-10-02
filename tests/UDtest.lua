-- Userdata Manager test

local _test = {}
local UDM = require "../UserdataManager"

--[[ 
    A userdata should be structured like this:
    - uuid: a user's unique id
    - available_decks: which decks are available to user
]]--

-- Test 1 : Serializing userdata and checking its content
local function func1()
    UDM.serialize({uuid="c4cf352e-56d7-48a6-b9b1-261006dea5dc", available_deck={}})
    t1 = UDM.deserialize("c4cf352e-56d7-48a6-b9b1-261006dea5dc")
    assert(t1.uuid == "c4cf352e-56d7-48a6-b9b1-261006dea5dc" and type(t1.available_deck)=="table", "Test #1 failed")
end

function _test.test_all()
    func1()
    print("Passed all UserDataManager tests")
end

return _test