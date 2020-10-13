local UDT = require "./UDtest"
local CRT = require "./CRtest"
local FT = require "./Ftest"
local EM = require "./EMtest"

local _Itest = {}

function _Itest.test_all()
    EM.test_all()
    CT.test_all()
    UDT.test_all()
    CRT.test_all()
    FT.test_all()
    print("All tests were successful, able to continue")
end

return _Itest