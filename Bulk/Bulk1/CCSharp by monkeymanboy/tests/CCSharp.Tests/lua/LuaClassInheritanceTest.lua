Animal = ({})
Animal.__index = Animal
Animal._CSharpTypes = ({"Animal", "Object"})
function Animal.new(name, _initializer)
 local self = setmetatable(({}), Animal);
 self.Name = name
 if _initializer then
  for _initializerKey,_initializerValue in pairs(_initializer) do
   self[_initializerKey] = _initializerValue
  end
 end
 return self;
end
function Animal:MakeNoise()
 print(self.Name.." makes a noise!")
end
Human = setmetatable(({}), Animal)
Human.__index = Human
Human._CSharpTypes = ({"Human", "Animal", "Object"})
function Human.new(name, _initializer)
 local self = setmetatable(Animal.new(name, ({})), Human);
 if _initializer then
  for _initializerKey,_initializerValue in pairs(_initializer) do
   self[_initializerKey] = _initializerValue
  end
 end
 return self;
end
Dog = setmetatable(({}), Animal)
Dog.__index = Dog
Dog._CSharpTypes = ({"Dog", "Animal", "Object"})
function Dog.new(name, _initializer)
 local self = setmetatable(Animal.new(name, ({})), Dog);
 if _initializer then
  for _initializerKey,_initializerValue in pairs(_initializer) do
   self[_initializerKey] = _initializerValue
  end
 end
 return self;
end
function Dog:MakeNoise()
 print(self["Name"].." goes woof!")
end
Cat = setmetatable(({}), Animal)
Cat.__index = Cat
Cat._CSharpTypes = ({"Cat", "Animal", "Object"})
function Cat.new(name, _initializer)
 local self = setmetatable(Animal.new(name, ({})), Cat);
 if _initializer then
  for _initializerKey,_initializerValue in pairs(_initializer) do
   self[_initializerKey] = _initializerValue
  end
 end
 return self;
end
function Cat:MakeNoise()
 print(self["Name"].." goes meow!")
end
local _TableArrayContains = function(tbl, elem) for _, v in ipairs(tbl) do if v == elem then return true; end end return false; end
function Start()
 local human = Human.new("Bob");
 local dog = Dog.new("Charlie");
 local cat = Cat.new("Chowder");
 human:MakeNoise()
 dog:MakeNoise()
 cat:MakeNoise()
 local animal = cat;
 local cat2 = (_TableArrayContains(animal["_CSharpTypes"], "Cat") and animal) or nil;
 if cat2~=nil then
  print(cat2["Name"].." is a cat")
 end
 local dog2 = (_TableArrayContains(animal["_CSharpTypes"], "Dog") and animal) or nil;
 if dog2==nil then
  print(animal["Name"].." is not a dog")
 end
 if _TableArrayContains(({cat, dog})[1]["_CSharpTypes"], "Cat") then
  print("list starts with a cat")
 end
end
Start()