Person = ({})
Person.__index = Person
Person._CSharpTypes = ({"Person", "Object"})
function Person.new(firstName, _initializer)
 local self = setmetatable(({}), Person);
 self.Name = firstName
 if _initializer then
  for _initializerKey,_initializerValue in pairs(_initializer) do
   self[_initializerKey] = _initializerValue
  end
 end
 return self;
end
function Person.new2(firstName, lastName, _initializer)
 local self = setmetatable(({}), Person);
 self.Name = (firstName.." ")..lastName
 if _initializer then
  for _initializerKey,_initializerValue in pairs(_initializer) do
   self[_initializerKey] = _initializerValue
  end
 end
 return self;
end
function Person:Greet(greeting)
 print(((greeting.." ")..self.Name).."!")
end

function Start()
 uniqueIdentifier = Person.new("gh")
 local person = Person.new("Bob");
 person:Greet("Hi")
 local person2 = Person.new2("Bob", "Boberson");
 person2:Greet("Hola")
end
Start()