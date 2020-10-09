-- Card Registry test

local _test = {}
local CardRegistry = require "../CardRegistry"

-- Test #1. Registring card dummy and validating it
local function test1()
    dummy = {
        name_id = "dummy_card",
        type = "MOB",
        mob_id = "dummy"
    }
    CardRegistry.register(dummy)
    target = CardRegistry.get("dummy_card")
    assert(
        dummy.name_id == target.name_id and
        dummy.type == target.type,
        "#1. Registered card data and actual card data doesn't match"
    )
end

-- Test #2. Filtering invalid card
local function test2()
    invalid = {
        type="MOB"
    }
    local stat, err = pcall(function()
        CardRegistry.register(invalid)
    end)
    assert(not stat, "Test #2 failed")
end

function _test.test_all()
    test1()
    test2()
    print("Passed all CardRegistry tests")
end

return _test