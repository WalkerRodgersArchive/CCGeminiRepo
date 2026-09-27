--[[
TrainLib by Herr Katze
Licensed MIT
]]
local expect = require("trainlib.internal.expect") -- Must use the internal version since CC's implementation doesn't support expecting only a display type
local trainlib = {}
local scheduleMetaTable = {
    __index = {
        addEntry = function(self,entry)
            expect(1,entry,"trainlib.entry")
            table.insert(self.entries,entry)
            return self
        end,
        setEntry = function(self,pos,entry)
            expect(1,pos,"number")
            expect(2,entry,"trainlib.entry")
            self.entries[pos] = entry
            return self
        end,
        getEntry = function(self,pos)
            expect(1,pos,"number")
            return self.entries[pos]
        end
    },
    __name = "trainlib.schedule"
}
local entryMetaTable = {
    __name = "trainlib.entry"
}
local condition_set_or_metatable = {
    __name = "trainlib.condition_set_or",
    __index = {
        addCondition = function(self,condition)
            expect(1,condition,"trainlib.condition","trainlib.condition_set_and")
            if getmetatable(condition).__name == "trainlib.condition" then
                condition = trainlib.condition_set_and():addCondition(condition)
            end
            table.insert(self,condition)
            return self
        end
    }
}
local condition_set_and_metatable = {
    __name = "trainlib.condition_set_or",
    __index = {
        addCondition = function(self,condition)
            expect(1,condition,"trainlib.condition")
            table.insert(self,condition)
            return self
        end
    }
}
local condition_metatable = {
    __name = "trainlib.condition"
}
local instruction_metatable = {
    __name = "trainlib.instruction"
}
local item_metatable = {
    __name = "trainlib.item"
}

function trainlib.schedule(cyclic)
    expect(1,cyclic,"boolean","nil")
    cyclic = cyclic or false
    return setmetatable({cyclic=cyclic,entries={}},scheduleMetaTable)
end

function trainlib.entry(instruction,conditions)
    expect(1,instruction,"trainlib.instruction")
    expect(2,conditions,"trainlib.condition_set_or")
    return setmetatable({instruction=instruction,conditions=conditions},entryMetaTable)
end

function trainlib.condition_set_or()
    return setmetatable({},condition_set_or_metatable)
end

function trainlib.condition_set_and()
    return setmetatable({},condition_set_and_metatable)
end

local function condition(condition_type,data)
    return setmetatable({id=condition_type,data=data},condition_metatable)
end

local itemFactoryMetatable = {
    __call = function(_,item,count)
        expect(1,item,"string","table")
        expect(2,count,"number","nil")
        if type(item) == "string" then
            return trainlib.item.from_id(item,count)
        else
            return trainlib.item.from_inventory(item)
        end
    end
}

trainlib.item = setmetatable({},itemFactoryMetatable)
function trainlib.item.from_inventory(item)
    return setmetatable({id=item.name,count=item.count},item_metatable)
end
function trainlib.item.from_id(id,count)
    return setmetatable({id=id,count=count},item_metatable)
end


trainlib.conditions = {}


function trainlib.conditions.custom(condition_type,data)
    expect(1,condition_type,"string")
    expect(1,data,"table")
    return condition(instruction_type,data)
end

function trainlib.conditions.delay(value,time_unit)
    expect(1,value,"number")
    expect(2,time_unit,"number")
    expect.range(time_unit,0,2)
    return condition("create:delay",{value=value,time_unit=time_unit})
end

function trainlib.conditions.time_of_day(hour,minute,rotation)
    expect(1,hour,"number")
    expect(2,minute,"number")
    expect(3,rotation,"number")
    expect.range(hour,0,23)
    expect.range(minute,0,59)
    expect.range(rotation,0,9)
    return condition("create:time_of_day",{hour=hour,minute=minute,rotation=rotation})
end

function trainlib.conditions.fluid_threshold(bucket,threshold,operator)
    expect(1,bucket,"trainlib.item")
    expect(2,threshold,"number")
    expect(3,operator,"number")
    expect.range(operator,0,2)
    return condition("create:fluid_threshold",{bucket=bucket,threshold=threshold,operator,operator,measure=0})
end

function trainlib.conditions.item_threshold(item,threshold,operator,stack)
    expect(1,item,"trainlib.item","table")
    expect.field(item,"id","string")
    expect.field(item,"count","number")
    expect(2,threshold,"number")
    expect(3,operator,"number")
    expect.range(operator,0,2)
    expect(4,stack,"boolean")
    stack = stack and 1 or 0 -- convert boolean to number for Create
    return condition("create:item_threshold",{item=item,threshold=threshold,operator=operator,measure=stack})
end

function trainlib.conditions.redstone_link(item1,item2,inverted)
    expect(1,item1,"trainlib.item")
    expect.field(item1,"id","string")
    expect.field(item1,"count","number")
    expect(2,item2,"trainlib.item")
    expect.field(item2,"id","string")
    expect.field(item2,"count","number")
    expect(3,inverted,"boolean")
    inverted = inverted and 1 or 0
    return condition("create:redstone_link",{frequency={item1,item2},inverted=inverted})
end

function trainlib.conditions.player_count(count,exact)
    expect(1,count,"number")
    expect(2,exact,"boolean")
    exact = exact and 0 or 1 -- invert this so it makes sense with booleans
    return condition("create:player_count",{count=count,exact=exact})
end

function trainlib.conditions.idle(value,time_unit)
    expect(1,value,"number")
    expect(2,value,"number")
    expect.range(time_unit,0,2)
    return condition("create:idle",{value=value,time_unit=time_unit})
end

function trainlib.conditions.unloaded()
    return condition("create:unloaded",{})
end

function trainlib.conditions.powered()
    return condition("create:powered",{})
end

trainlib.instructions = {}
local function instruction(instruction_type,data)
    return setmetatable({id=instruction_type,data=data},instruction_metatable)
end

function trainlib.instructions.custom(instruction_type,data)
    expect(1,instruction_type,"string")
    expect(1,data,"table")
    return instruction(instruction_type,data)
end
function trainlib.instructions.destination(destination)
    expect(1,destination,"string")
    return instruction("create:destination",{text=destination})
end

function trainlib.instructions.rename(name)
    expect(1,name,"string")
    return instruction("create:rename",{text=name})
end

function trainlib.instructions.throttle(value)
    expect(1,value,"number")
    return instruction("create:throttle",{value=value})
end

function trainlib.instructions.retrieve_package(filter)
    filter = filter or ""
    expect(1,filter,"string")
    return instruction("create:package_retrieval",{text=filter})
end
function trainlib.instructions.deliver_package()
    return instruction("create:package_delivery",{})
end
return trainlib