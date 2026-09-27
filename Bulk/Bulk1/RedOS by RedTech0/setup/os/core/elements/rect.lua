os.loadAPI("./elements/vector")
os.loadAPI("./elements/object")

function New(x, y, width, height)
  local pos
  local dims
  
  if type(x) == "number" and type(y) == "number" and type(width) == "number" and type(height) == "number" then
    pos = vector.New(x, y)
    dims = vector.New(width, height)
  elseif type(x) == "table" and x.GetType() == "Vector" and type(y) == "table" and y.GetType() == "Vector" then
    pos = x
    dims = y
  else
    error("Parameters must be either 4 Numbers or 2 Vectors.")
  end

  local self = object.New("Rect")

  function self.GetTop() return pos.Y end
  function self.GetLeft() return pos.X end
  function self.GetBottom() return pos.Y + dims.Y end
  function self.GetRight() return pos.X + dims.X end

  function self.GetPosition() return pos end
  function self.GetSize() return dims end

  function self.SetPosition(newPos)
    if not type(newPos) == "table" or not newPos.GetType() == "Vector" then
      error("newPos must be a Vector")
    end
    
    pos = newPos
  end

  function self.SetSize(newSize)
    if not type(newSize) == "table" or not newSize.GetType() == "Vector" then
      error("newSize must be a Vector")
    end
    
    dims = newSize
  end

  function self.Contains(otherRect)
    if not type(otherRect) == "table" or not otherRect.GetType() == "Rect" then
      error("Parameter must be a Rect")
    end

    return otherRect.GetTop() >= self.GetTop() and
           otherRect.GetBottom() <= self.GetBottom() and
           otherRect.GetLeft() >= self.GetLeft() and
           otherRect.GetRight() <= self.GetRight()
  end

  function self.ContainsPoint(arg1, arg2)
    local pos

    if type(arg1) == "number" and type(arg2) == "number" then
      pos = vector.New(arg1, arg2)
    elseif type(arg1) == "table" and arg1.GetType() == "Vector" then
      pos = arg1
    else
      error("Parameters must be either 2 Numbers or a Vector.")
    end

    return pos.Y >= self.GetTop() and
           pos.Y <= self.GetBottom() and
           pos.X >= self.GetLeft() and
           pos.X <= self.GetRight()
  end

  function self.Overlaps(otherRect)
    if self.ContainsPoint(otherRect.GetLeft(), otherRect.GetTop()) then
      return true

    elseif self.ContainsPoint(otherRect.GetLeft(), otherRect.GetBottom()) then
      return true

    elseif self.ContainsPoint(otherRect.GetRight(), otherRect.GetTop()) then
      return true

    elseif self.ContainsPoint(otherRect.GetRight(), otherRect.GetBottom()) then
      return true

    else
      return false
    end
  end

  return self
end

function Copy(rect)
  return New(vector.Copy(rect.GetPosition()), vector.Copy(rect.GetSize()))
end