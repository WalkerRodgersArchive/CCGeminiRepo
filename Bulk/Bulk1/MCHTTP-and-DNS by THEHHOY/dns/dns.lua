local path = "lookup"
local modem = peripheral.find("modem")

function readFile(file)
    local handle = fs.open(file,"r")
    return handle.readAll()
end
function writeFile(file,data)
    local handle = fs.open(file,"w")
    handle.write(data)
    handle.close()
end

local data = readFile(path)
local lookup = textutils.unserialise(data)

local dnsOpen = true

modem.open(8080)

while dnsOpen do
    local ev = {os.pullEvent("modem_message")}
    local packet = ev[5]
    if packet.to == os.getComputerID() then
        print("ID Right")
        local address = lookup[packet.address]
        if address then
            print("address Right")
            modem.transmit(8080,8080,{
                to = packet.from,
                address = address,
                status = 200
            })
        else
            modem.transmit(8080,8080,{
                to = packet.from,
                address = address,
                status = 404
            })
        end
    end
end

writeFile(textutils.serialise(lookup))
