local linq = require("linq")
function Start()
 local array = {peripheral.find("inventory")};
 local array2 = array;
 for _,inventory in ipairs(array2) do
  print("Contents of: "..tostring(peripheral.getName(inventory)))
  print("------------------")
  local array3 = linq.from(inventory.list()):groupBy(function(x)
  return x["name"];
end):toTable();
  for _,source in ipairs(array3) do
   local name = linq.from(source):first()["name"];
   print((name..": ")..tostring(linq.from(source):sum(function(x)
  return x["count"];
end)))
  end
  print()
 end
end
Start()