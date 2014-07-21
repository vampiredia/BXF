-----------------------------------------------------------------------------
-- UNIT FUNCTIONS FOR WHOME
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Imports and dependencies
-----------------------------------------------------------------------------
local math = require('math')
local string = require("string")
local table = require("table")

local base = _G

-----------------------------------------------------------------------------
-- Module declaration
-----------------------------------------------------------------------------
module("unit")

-- Public functions

-- Private functions

-----------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
-----------------------------------------------------------------------------
--- Encodes an arbitrary Lua object / variable.
-- @param v The Lua object / variable to be JSON encoded.
-- @return String containing the JSON encoding in internal Lua string format (i.e. not unicode)
