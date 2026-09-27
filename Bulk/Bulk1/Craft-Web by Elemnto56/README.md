## What is Craft-Web?

Craft-Web is a CC:T program that allows users to share CML files with each other. This can be useful in cases such as sharing data or user-made things such as messages. 

## What Purpose Does Craft-Web Serve?
Craft-Web is built to allow data that's far way to be transferred to you easily. In addition, CML (Craft's Markup Language) is made in a way that allows you to easily write down data from other scripts. 

## Getting Started

1. Get two Advanced computers and place them
2. Get either two wireless modems or two wired modems and attach each to the back of each computer
    - *Note:* If you used wired modems, connect both of them via Networking Cables
3. On one computer, run `pastebin get https://pastebin.com/DR3X5dT6 rtc.lua` (This will be your server)
    - *Optional:* Run `pastebin get https://pastebin.com/p1AUrG4G example.lua` for a CML file to have
4. On the other computer run `wget https://raw.githubusercontent.com/Elemnto56/Craft-Web/refs/heads/main/craft-installer.lua`
    1. Execute the `craft-installer` and follow the prompts
    2. Once all is installed, the `craft-installer` can be removed
5. Open `craft-web` on the computer that installed it
6. Click the address bar, and type in an address based on the syntax: `cw://[id of server computer]?[path to cml]
    - *Example:* `cw://0?/example.cml`
7. Click Enter

## Upcoming Features
- A `PUT` method that allows client to send CML files to the server
- Correct rendering on all devices, and not just advanced computers (pocketcomputers, monitors, etc)
- Allowing `http` requests to grab CML files from the irl internet
- Possibly a better UI?
