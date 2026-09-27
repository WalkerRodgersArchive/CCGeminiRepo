return function (api)
    local fl = api.vendor.fluent
    local fn = fl.fn

    local BaseBiggerReactorsInputAdapter = api.mintInput('BaseBiggerReactorsInputAdapter')

    function BaseBiggerReactorsInputAdapter:constructor (peripheralName, categories)
        self:super('constructor')

        self.prefix = 'br:'

        self.categories = categories or { 'basic' }

        ---@type table<string, table<string, cyberbit.Fluent>>
        self.queries = {}

        ---@type cyberbit.Fluent[]
        self.storageQueries = {}

        -- boot components
        self:setBoot(function ()
            self.components = {}

            self:addComponentByPeripheralID(peripheralName)
        end)()

        self:beforeRegister()

        self:register()
    end

    function BaseBiggerReactorsInputAdapter:beforeRegister ()
        -- nothing by default, should be overridden by subclasses
    end

    function BaseBiggerReactorsInputAdapter:register ()
        local allCategories = fl(self.queries):keys():result()

        if self.categories == '*' then
            self.categories = allCategories
        elseif type(self.categories) == 'table' then
            self.categories = fl(self.categories):intersect(allCategories):result()
        else
            error('categories must be a list of categories or "*"')
        end

        return self
    end

    function BaseBiggerReactorsInputAdapter:withGenericMachineQueries ()
        self.queries.basic = self.queries.basic or {}
        
        self.queries.basic.active       = fn():call('active'):toFlag()
        self.queries.basic.connected    = fn():call('connected'):toFlag()

        return self
    end

    function BaseBiggerReactorsInputAdapter:withGeneratorQueries ()
        self.queries.basic = self.queries.basic or {}
        self.queries.energy = self.queries.energy or {}

        local battery = fn():call('battery')

        self.queries.basic.production_rate  = battery:call('producedLastTick'):energyRate()
        self.queries.energy.energy          = battery:call('stored'):energy()
        self.queries.energy.energy_capacity = battery:call('capacity'):energy()

        return self
    end

    local function queueHelper (results, index, query)
        return function ()
            results[index] = api.Metric(query:metricable():result())
        end
    end

    function BaseBiggerReactorsInputAdapter:read ()
        self:boot()
        
        local source, component = next(self.components)

        local tempMetrics = {}
        local queue = {}

        -- queue single-metric queries
        for _, category in ipairs(self.categories) do
            for k, v in pairs(self.queries[category]) do
                table.insert(queue, queueHelper(
                    tempMetrics,
                    #queue + 1,
                    v:from(component):with('name', self.prefix .. k):with('source', source)
                ))
            end
        end

        -- queue storage queries, which may return multiple metrics
        -- these have no category and are always included
        for k, v in pairs(self.storageQueries) do
            table.insert(queue, function ()
                local tempResult = v:from(component):result()

                for _, metric in ipairs(tempResult) do
                    metric.name = 'storage:' .. metric.name
                    metric.source = source

                    table.insert(tempMetrics, metric)
                end
            end)
        end

        parallel.waitForAll(table.unpack(queue))

        return api.MetricCollection(table.unpack(tempMetrics))
    end

    ------ Static Methods ------

    function BaseBiggerReactorsInputAdapter.mintAdapter (type)
        local adapter = api.ObjectModel.class(BaseBiggerReactorsInputAdapter)
        adapter.type = type

        function adapter:constructor (peripheralName, categories)
            self:super('constructor', peripheralName, categories)
        end

        return adapter
    end

    return BaseBiggerReactorsInputAdapter
end