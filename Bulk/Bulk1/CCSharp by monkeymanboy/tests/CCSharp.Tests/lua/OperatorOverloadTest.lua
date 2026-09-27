Vector3 = ({})
Vector3.__index = Vector3
Vector3._CSharpTypes = ({"Vector3", "Object"})
function Vector3.new(x, y, z, _initializer)
 local self = setmetatable(({["X"]=0, ["Y"]=0, ["Z"]=0}), Vector3);
 self.X = x
 self.Y = y
 self.Z = z
 if _initializer then
  for _initializerKey,_initializerValue in pairs(_initializer) do
   self[_initializerKey] = _initializerValue
  end
 end
 return self;
end
Vector3.__add = function(a, b)
  return Vector3.new(a["X"]+b["X"], a["Y"]+b["Y"], a["Z"]+b["Z"]);
end
Vector3.__sub = function(a, b)
  return Vector3.new(a["X"]-b["X"], a["Y"]-b["Y"], a["Z"]-b["Z"]);
end
Vector3.__mul = function(a, b)
  return Vector3.new(a["X"]*b["X"], a["Y"]*b["Y"], a["Z"]*b["Z"]);
end
Vector3.__unm = function(vector)
  return Vector3.new(0-vector["X"], 0-vector["Y"], 0-vector["Z"]);
end
Vector3.__eq = function(a, b)
  return ((a["X"]==b["X"]) and (a["Y"]==b["Y"])) and (a["Z"]==b["Z"]);
end

Vector3.__tostring = function(self)
  return ((((("("..tostring(self.X))..", ")..tostring(self.Y))..", ")..tostring(self.Z))..")";
end
function Start()
 local a = Vector3.new(10, 10, 10);
 local vector = Vector3.new(0, 0, 5);
 print(a+vector)
 print(a*vector)
 print(-vector)
 print(a==vector)
end
Start()