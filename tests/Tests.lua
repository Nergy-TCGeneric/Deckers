local UDT = require "./tests/UDtest"
local CRT = require "./tests/CRtest"
local FT = require "./tests/Ftest"
local EM = require "./tests/EMtest"

local _Itest = {}

function _Itest.test_all()
    EM.test_all()
    UDT.test_all()
    CRT.test_all()
    FT.test_all()
    print("All tests were successful, able to continue")
end

return _Itest