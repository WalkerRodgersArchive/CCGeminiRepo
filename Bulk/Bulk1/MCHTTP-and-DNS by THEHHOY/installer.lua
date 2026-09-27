local githubPage = "https://raw.githubusercontent.com/THEHHOY/MCHTTP-and-DNS/refs/heads/main/"
local files = {
    "client/mchttp.lua",
    "client/craftium.lua",
    "client/browser.lua",
    "client/dnsapi.lua",
    "dns/dns.lua",
    "dns/lookup",
    "server/mchttp-server.lua",
    "server/server.lua"
}

for i,a in ipairs(files) do
    print(i,a)
end
write("Write number to install: ")
local ans = tonumber(read())
local req = http.get(githubPage..files[ans])
local data = req.readAll()
local handle = fs.open(files[ans],"w")
handle.write(data)
handle.close()
