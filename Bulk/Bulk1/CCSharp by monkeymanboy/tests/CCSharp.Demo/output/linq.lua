--CCSharp Linq Ver 0.0.1
local linq = {}
linq.__index = linq

local function isArray(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

function linq.from(tbl)
    local self = setmetatable({}, linq)
    self._isArray = isArray(tbl)
    self._base = tbl
    self._pipeline = {}
    return self
end

function linq:_addOp(op)
    table.insert(self._pipeline, op)
    return self
end

function linq:_getIterator()
    local t = self._base
    if self._isArray then
        local i = 0
        return function()
            i = i + 1
            if t[i] ~= nil then
                return i, t[i]
            end
        end
    else
        local k
        return function()
            k = next(t, k)
            if k ~= nil then
                return k, t[k]
            end
        end
    end
end

function linq:_applyPipeline()
    local iter = self:_getIterator()
    for _, op in ipairs(self._pipeline) do
        iter = op(iter)
    end
    return iter
end

function linq:where(predicate)
    return self:_addOp(function(iter)
        return function()
            while true do
                local k, v = iter()
                if k == nil then return end
                if predicate(v, k) then
                    return k, v
                end
            end
        end
    end)
end

function linq:select(selector)
    return self:_addOp(function(iter)
        return function()
            local k, v = iter()
            if k ~= nil then
                return k, selector(v, k)
            end
        end
    end)
end

function linq:distinct(keySelector)
    keySelector = keySelector or function(v) return v end
    return self:_addOp(function(iter)
        local seen = {}
        return function()
            while true do
                local k, v = iter()
                if k == nil then return end
                local key = keySelector(v, k)
                if not seen[key] then
                    seen[key] = true
                    return k, v
                end
            end
        end
    end)
end

function linq:groupBy(keySelector)
    return self:_addOp(function(iter)
        local groups = {}
        local built = false
        local keys = {}
        local index = 0

        return function()
            if not built then
                for k, v in iter do
                    local key = keySelector(v, k)
                    if not groups[key] then
                        groups[key] = {}
                        table.insert(keys, key)
                    end
                    table.insert(groups[key], v)
                end
                built = true
            end
            index = index + 1
            local k = keys[index]
            if k then
                return k, groups[k]
            end
        end
    end)
end

function linq:orderBy(keySelector)
    return self:_addOp(function(iter)
        local sorted = {}
        local i = 0
        local built = false
        return function()
            if not built then
                for _, v in iter do
                    table.insert(sorted, v)
                end
                table.sort(sorted, function(a, b)
                    return keySelector(a) < keySelector(b)
                end)
                built = true
            end
            i = i + 1
            if i <= #sorted then
                return i, sorted[i]
            end
        end
    end)
end

function linq:orderByDescending(keySelector)
    return self:_addOp(function(iter)
        local sorted = {}
        local i = 0
        local built = false
        return function()
            if not built then
                for _, v in iter do
                    table.insert(sorted, v)
                end
                table.sort(sorted, function(a, b)
                    return keySelector(a) > keySelector(b)
                end)
                built = true
            end
            i = i + 1
            if i <= #sorted then
                return i, sorted[i]
            end
        end
    end)
end

function linq:take(n)
    return self:_addOp(function(iter)
        local count = 0
        return function()
            if count >= n then return end
            local k, v = iter()
            if k ~= nil then
                count = count + 1
                return k, v
            end
        end
    end)
end

-- Terminal methods

function linq:toTable()
    local result = self._isArray and {} or {}
    for k, v in self:_applyPipeline() do
        if self._isArray then
            table.insert(result, v)
        else
            result[k] = v
        end
    end
    return result
end

function linq:first()
    for _, v in self:_applyPipeline() do
        return v
    end
    error("Sequence contains no elements")
end

function linq:firstOrDefault(default)
    for _, v in self:_applyPipeline() do
        return v
    end
    return default
end

function linq:count()
    local c = 0
    for _ in self:_applyPipeline() do
        c = c + 1
    end
    return c
end

function linq:any(predicate)
    local iter = self:_applyPipeline()
    if predicate == nil then
        for _ in iter do return true end
    else
        for k, v in iter do
            if predicate(v, k) then return true end
        end
    end
    return false
end

function linq:all(predicate)
    for k, v in self:_applyPipeline() do
        if not predicate(v, k) then return false end
    end
    return true
end

return linq
