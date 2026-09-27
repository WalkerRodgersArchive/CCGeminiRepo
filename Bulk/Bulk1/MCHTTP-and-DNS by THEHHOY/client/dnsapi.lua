local api = {}

api.MODEM = peripheral.find("modem")

function api.lookup(address,timeout)
    settings.define("networking.dns",{
        description = "Default DNS",
        default = 51,
        type = "number"
    })
    local modem = api.MODEM
    modem.transmit(8080,8080,{
        from = os.computerID(),
        to = settings.get("networking.dns"),
        address = address
    })
    local timer = os.startTimer(timeout)
    local ev = {}
    local status = nil
    modem.open(8080)
    repeat
        ev = {os.pullEvent()}
        if ev[1] == "modem_message" then
            local pack = ev[5]
            if pack.to == os.computerID() then
                status = pack
            end
        elseif ev[2] == timer then
            status = 176
        end
    until status ~= nil
    modem.close(8080)
    if status == 176 then
        return nil,"DNS Didn't respond."
    elseif status.status == 404 then
        return nil,"Address not found."
    else
        return status.address    
    end
end

return api
