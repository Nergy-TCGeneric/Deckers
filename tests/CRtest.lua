-- Card Registry test

local _test = {}
local CardRegistry = require "../CardRegistry"

-- Test #1. Registring card dummy and validating it
local function test1()
    dummy = {
        lifepoint = 15,
        type = "MOB",
        atk_str = 2,
        id = "dummy_card1"
    }
    CardRegistry.register(dummy)
    target = CardRegistry.get("dummy_card1")
    assert(
        dummy.lifepoint == target.lifepoint
        and dummy.type == target.type
        and dummy.atk_str == target.atk_str
        and dummy.id == target.id,
        "Test #1 failed"
    )
end

-- Test #2. Filtering invalid card
local function test2()
    invalid = {
        lifepoint = 20,
        type = "INVALID_TYPE",
        atk_str = 2,
        id = "invalid_card"
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