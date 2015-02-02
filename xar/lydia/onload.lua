local path = __document
local index = string.find(path, "/[^/]*$")
local rootDir = string.sub(path,1,index)
