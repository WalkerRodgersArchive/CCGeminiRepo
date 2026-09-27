local function 

local function convertPath(p)
    if type(p) ~= "string" then
        return p
    end
    local p2 = shell.resolve(p)
    if p2:sub(1, 3) == "../" 
  
