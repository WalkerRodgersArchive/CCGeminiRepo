os.loadAPI("./elements/object")

function New(x, y)
  local self = object.New("Vector")
  self.X = x
  self.Y = y

  function self.Inverse()
    return New(-self.X, -self.Y)
  end

  return self
end

function Copy(vec)
  return New(vec.X, vec.Y)
end

function One() return Copy(New(1,1)) end
function Zero() return Copy(New(0,0)) end
function Left() return Copy(New(-1, 0)) end
function Up() return Copy(New(0, -1)) end
function Right() return Copy(New(1, 0)) end
function Down() return Copy(New(0, 1)) end