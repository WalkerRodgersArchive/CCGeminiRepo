print("Installing Craft-Web")
shell.run("wget https://raw.githubusercontent.com/Elemnto56/Craft-Web/refs/heads/main/craft-web.lua")
shell.run("wget https://raw.githubusercontent.com/Elemnto56/Craft-Web/refs/heads/main/window-launch.lua")

local x = ""
if #fs.find("pixelui") == 0 then    
    while true do
        print("Craft-Web requires a modified PixelUI to operate. Do you want me to install it? (y/n)")
        x = io.stdin._handle.readLine()

        if x == "y" then
            print("Installing PixelUI...")
            shell.run("wget https://raw.githubusercontent.com/Elemnto56/Craft-Web/refs/heads/main/pixelui.lua")
            print("Done! Goodbye.")
            os.queueEvent("terminate")
            sleep(2)
        else if x == "n" then
            print("Goodbye!")
            os.queueEvent("terminate")
            sleep(2)
        else 
            printError("That was not an option.")
        end
        sleep(1)
        if x == "y" or x == "n" then break end
    end
end end
