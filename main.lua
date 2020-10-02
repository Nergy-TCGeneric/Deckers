package.path = './?.lua;' .. package.path
local tests = require "./tests/Tests"

tests.test_all()