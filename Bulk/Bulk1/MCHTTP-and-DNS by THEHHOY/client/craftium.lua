local api = {}

function api.startInstance(siteData,terminal,mchttp)
    local tX,tY = terminal.getSize()
    local env = {
        term = window.create(terminal,1,2,tX,tY),
        os = {
            pullEvent = os.pullEvent,
            queueEvent = os.queueEvent,
            startTimer = os.startTimer,
            cancelTimer = os.cancelTimer,
            sleep = sleep,
            time = os.time,
            date = os.date,
        },
        sleep = sleep,
        keys = keys,
        colors = colors,
        colours = colours,
        error = error,
        window = window
    } 
    if mchttp then
        env.mchttp = mchttp
    end
    local func, err = load(siteData,"site",nil,env)
    if err then
        error(err)
    else
        func()
    end
end

return api
