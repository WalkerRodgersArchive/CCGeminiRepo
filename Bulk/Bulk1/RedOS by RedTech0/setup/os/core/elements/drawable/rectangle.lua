os.loadAPI("./colours")
os.loadAPI("./elements/object")

function New(bounds, colour, borderThickness, borderColour)
  if not type(bounds) == "table" or not bounds.GetType() == "Rect" then
    error("bounds must be of type Rect!")
  end

  if not type(colour) == "number" or not colour.GetType() == "ColourStruct" then
    error("colour is not a valid colour!")
  end

  if type(colour) == "number" then
    colour = colours.FindColourStructByDecimal(colour)
  end

  borderThickness = borderThickness or 0
  borderColour = borderColour or colours.Black

  if not type(borderThickness) == "number" or borderThickness < 0 then
    error("borderThickness must be 0 or a positive number!")
  end

  if not type(borderColour) == "number" or not borderColour.GetType() == "ColourStruct" then
    error("borderColour is not a valid colour!")
  end

  if type(borderColour) == "number" then
    borderColour = colours.FindColourStructByDecimal(borderColour)
  end

  local self = object.New("Rectangle")
  
  function self.GetBounds() return bounds end

  function self.Draw()
    local lastPosX, lastPosY = term.getCursorPos()

    local pos = bounds.GetPosition()
    local dims = bounds.GetSize()

    local borderLine = string.rep(borderColour.GetPaint(), dims.X)
    local borderEdge = string.rep(borderColour.GetPaint(), borderThickness)
    local fillLine = borderEdge..string.rep(colour.GetPaint(), dims.X - (borderThickness * 2))..borderEdge

    for i = 0, dims.Y - 1, 1 do
      term.setCursorPos(pos.X, pos.Y + i)
      
      if i < borderThickness or i > dims.Y - 1 - borderThickness then
        term.blit(string.rep(" ", dims.X), borderLine, borderLine)
      else
        term.blit(string.rep(" ", dims.X), fillLine, fillLine)
      end
    end

    term.setCursorPos(lastPosX, lastPosY)
  end

  return self
end