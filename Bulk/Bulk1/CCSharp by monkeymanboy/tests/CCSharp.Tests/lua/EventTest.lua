function Start()
 while true do
  local cCEvent = {os.pullEvent()};
  local cCEvent2 = cCEvent;
  local cCEvent3 = cCEvent2;
  local mouseClickEvent = (((cCEvent3~=nil) and (cCEvent3[1]=="mouse_click")) and cCEvent3) or nil;
  if mouseClickEvent==nil then
   local mouseDragEvent = (((cCEvent3~=nil) and (cCEvent3[1]=="mouse_drag")) and cCEvent3) or nil;
   if mouseDragEvent~=nil then
    print((((("Mouse Drag on button "..tostring(mouseDragEvent[2])).." at ")..tostring(mouseDragEvent[3]))..", ")..tostring(mouseDragEvent[4]))
   else
    print("Unhandled event: "..cCEvent[1])
   end
  else
   print((((("Mouse Click on button "..tostring(mouseClickEvent[2])).." at ")..tostring(mouseClickEvent[3]))..", ")..tostring(mouseClickEvent[4]))
  end
 end
end
Start()