function Start()
 local itemDetail = turtle.getItemDetail(1, true);
 if (itemDetail==nil) or (not (itemDetail["tags"]["minecraft:saplings"]~=nil)) then
  print("Please provide me saplings in my first slot to begin")
  while (itemDetail==nil) or (not (itemDetail["tags"]["minecraft:saplings"]~=nil)) do
   local turtleInventoryEvent = {os.pullEvent("turtle_inventory")};
   itemDetail = turtle.getItemDetail(1, true)
  end
 end
 local tuple = {turtle.inspect()};
 local item = tuple[1];
 local item2 = tuple[2];
 if item then
  if item2["tags"]["minecraft:logs"]~=nil then
   print("Placed in front of existing tree, breaking that tree first")
   BreakTree()
  else
   if item2["tags"]["minecraft:saplings"]~=nil then
    print("Placed in front of existing sapling, waiting for tree to grow")
    WaitForTree()
   end
  end
 end
 PlantAndWait()
end
function PlantAndWait()
 while true do
  local itemDetail = turtle.getItemDetail(1, true);
  if (itemDetail==nil) or (not (itemDetail["tags"]["minecraft:saplings"]~=nil)) then
   print("Ran out of saplings, please provide more")
   return nil;
  end
  turtle.select(1)
  if not turtle.place() then
   break
  end
  WaitForTree()
 end
 print("Unable to plant sapling, please clear space")
end
function WaitForTree()
 while true do
  local tuple = {turtle.inspect()};
  local item = tuple[1];
  local item2 = tuple[2];
  if item and (item2["tags"]["minecraft:logs"]~=nil) then
   break
  end
  os.sleep(10)
 end
 BreakTree()
end
function BreakTree()
 turtle.dig()
 while not turtle.forward() do
  AttemptRefuel()
 end
 while true do
  local tuple = {turtle.inspectUp()};
  local item = tuple[1];
  local item2 = tuple[2];
  if (not item) or (not (item2["tags"]["minecraft:logs"]~=nil)) then
   break
  end
  turtle.digUp()
  while not turtle.up() do
   AttemptRefuel()
  end
 end
 while true do
  local tuple2 = {turtle.inspectDown()};
  local item3 = tuple2[1];
  local item4 = tuple2[2];
  if item3 then
   if not (item4["tags"]["minecraft:logs"]~=nil) then
    break
   end
   turtle.digDown()
  end
  while not turtle.down() do
   AttemptRefuel()
  end
 end
 while not turtle.back() do
  AttemptRefuel()
 end
end
function AttemptRefuel()
 turtle.select(2)
 turtle.refuel(1)
end
Start()