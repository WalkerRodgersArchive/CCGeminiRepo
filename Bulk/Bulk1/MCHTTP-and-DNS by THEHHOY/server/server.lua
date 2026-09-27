local mchttpserver = require("mchttp-server")

local app = mchttpserver.new(80)

app:listen("/echo","GET",function(pack)
    return {body=pack.body,contentType="text/plain"}
end)

app:listen("/post","POST",function(pack)
    print("MSG:",pack.body)
end)

app:run()
