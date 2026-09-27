os.loadAPI("./elements/object")

local function CreateStruct(dec, name)
  local self = object.New("ColourStruct")
  function self.GetDecimal() return dec end
  function self.GetHex() return string.format("%02x", dec * 256) end
  function self.GetPaint() return string.format("%x", (math.log(dec) / math.log(2))) end
  function self.GetName() return name end

  return self
end

local colours = {
  white = CreateStruct(1, "White"),
  orange = CreateStruct(2, "Orange"),
  magenta = CreateStruct(4, "Magenta"),
  lightBlue = CreateStruct(8, "LightBlue"),
  yellow = CreateStruct(16, "Yellow"),
  lime = CreateStruct(32, "Lime"),
  pink = CreateStruct(64, "Pink"),
  grey = CreateStruct(128, "Grey"),
  lightGrey = CreateStruct(256, "LightGrey"),
  cyan = CreateStruct(512, "Cyan"),
  purple = CreateStruct(1024, "Purple"),
  blue = CreateStruct(2048, "Blue"),
  brown = CreateStruct(4096, "Brown"),
  green = CreateStruct(8192, "Green"),
  red = CreateStruct(16384, "Red"),
  black = CreateStruct(32768, "Black")
}

White = colours.white
Orange = colours.orange
Magenta = colours.magenta
LightBlue = colours.lightBlue
Yellow = colours.yellow
Lime = colours.lime
Pink = colours.pink
Grey = colours.grey
LightGrey = colours.lightGrey
Cyan = colours.cyan
Purple = colours.purple
Blue = colours.blue
Brown = colours.brown
Green = colours.green
Red = colours.red
Black = colours.black

function FindColourStructByDecimal(dec)
  return colours[(math.log (dec) / math.log (2)) + 1]
end

function FindColourStructByHex(hex)
  return tonumber(FindColourStructByDecimal(hex))
end

function FindColourStructByPaintID(id)
  return colours[tonumber(id, 16)]
end
