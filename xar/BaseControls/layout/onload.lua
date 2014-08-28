local path = __document
local index = string.find(path, "/[^/]*$")
local rootDir = string.sub(path,1,index)

XLLoadModule(rootDir.."TipsHelper.lua")["RegisterObject"]()

XLLoadModule(rootDir.."MenuHelper.lua")["RegisterObject"]()

XLLoadModule(rootDir.."Particle.Elements.lua")["RegisterObject"]()