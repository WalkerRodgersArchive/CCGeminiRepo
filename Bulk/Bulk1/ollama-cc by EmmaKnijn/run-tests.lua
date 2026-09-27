require("ollama")
local passAmount = 0
local failAmount = 0
for i,file in pairs(fs.list("tests")) do
    local pass, info = pcall(function() require("tests/" .. file:sub(1,-5))() end)
    local prettyPass = "[FAIL]"
    if pass then
        prettyPass = "[PASS]"
        pass, info = require("tests/" .. file:sub(1,-5))()
    end
    if not info then info = "" end
    if pass then 
        term.setTextColor(colors.lime)
        passAmount = passAmount + 1
    else
        term.setTextColor(colors.red)
        failAmount = failAmount + 1
    end
    term.write(prettyPass .. " ")
    term.setTextColor(colors.white)
    print(file .. ": " .. info)
end
print("")
if failAmount == 0 then
    term.setTextColor(colors.lime)
else
    term.setTextColor(colors.red)
end
print(passAmount .. " tests passed, " .. failAmount .. " tests failed")

term.setTextColor(colors.white)