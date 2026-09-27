local api = {}

api.MODEM = peripheral.find("modem")

function api.request(host,port,body,path,method,timeout)
    local modem = api.MODEM
    modem.transmit(port,100,{
        method=method,
        from = os.computerID(),
        host = host,
        path=path,
        headers={
            ["User-Agent"] = "mchttp-client/1.0"
        },
        body=body
    })
    if not timeout then timeout = 5 end
    if method == "GET" then
        local timer = os.startTimer(timeout)
        local ev = {}
        modem.open(100)
        local status = nil
        repeat
            ev = {os.pullEvent()}
            if ev[1] == "modem_message" then
                if ev[5].recipient == os.computerID() then
                    status = ev[5]
                end
            elseif ev[2] == timer then
                status = "TIMEOUT"
            end
        until status ~= nil
        if status == "TIMEOUT" then
            return {
                status = 176,
                headers = {},
                body = "No response (timeout)"
            }
        else
            return status
        end
    end
end

return api
