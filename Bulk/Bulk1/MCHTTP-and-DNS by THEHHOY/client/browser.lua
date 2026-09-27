local craftium = require("craftium")
local dns = require("dnsapi")
local mchttp = require("mchttp")

if type(arg[1]) ~= "string" then
    error("Argument 1 expected to be string",0)
end

if fs.exists(arg[1]) then
    local handle = fs.open(arg[1],"r")
    local data = handle.readAll()
    handle.close()
    craftium.startInstance(data,term.current())
else
    local addr, err = dns.lookup(arg[1],5)
    if addr then
        print(addr)
        local result = mchttp.request(addr,80,nil,"/","GET",5)
        if result.status == 176 then error(result.body,0) end
        craftium.startInstance(result.body,term.current(),mchttp)
    else
        error(err,0)
    end
end
