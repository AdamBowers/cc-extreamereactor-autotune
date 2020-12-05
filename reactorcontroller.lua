-- declaring local variables which are really just working as global variables but fuck off.
local reactor = peripheral.wrap("back")
local reactorBufferSize, reactorBufferTarget, reactorControlRodLvl, reactorBufferStore
local timeout, connected, energyProducedLastTick_, terminateScript, energyProductionTarget
local insufficientPowerProductionCount, load, dataset

-- default values to some common variables
reactorBufferSize = 10000000    -- mostly useless, but its a good reminder of the max buffer size
reactorBufferTarget = 9900000   -- the target bafore value, used by chargeBufferToTarget function to specify the threshold required befor the event block can end
ControlRodLvl = 0   -- default starting level of the control rod. gets altered to keep track of the control rod insertion
energyProducedLastTick_ = 0  -- keeps track of the energy being produced per game tic (1s/20)
terminateScript = 0  -- a state marker which is checked to see if the event loop should continue to run. 0 = keep going, 1 = stop dickhead.
energyProductionTarget = math.pow(2, 20)  -- arbitrary large number. this will get ultered to be the same as the load when that is computed
insufficientPowerProductionCount = 0  -- just a counter keep track of how many times insufficient power has been produced in during the operation of the script. if its = to 5 then stop the script. your reactor isn't powerful enough

connected = true  -- i dont even know

-- generic function used to capture an set a value of a variable to completely termiate the script, or just event loop if so desired
function captureTerminationKey (key_)
    timeout = os.startTimer(0.1)
    local event, key = os.pullEvent() -- catches all pullEvents
    if event == "key" and key == keys.x then
        print( "You pressed [x]. Exiting program..." )
        terminateScript = 1
        return 1
    end
end

-- holds the event loop until the buffer has charged to a target capacity
function chargebufferToTarget ()
    while(reactor.getEnergyStored() < reactorBufferTarget) do
        captureTerminationKey("x")
        if terminateScript == 1 then
            break
        end

        local energyStored1, energyStored2

        energyStored1 = reactor.getEnergyStored()
        os.startTimer(0.8)
        os.pullEvent( "timer" )
        energyStored2 = reactor.getEnergyStored()

        if energyStored2 < energyStored1 then
            insufficientPowerProductionCount = insufficientPowerProductionCount + 1
            print("insufficient power is being preduced. Unable to keep up with demand. ("..tostring(insufficientPowerProductionCount).."/5)")
            print("retesting production in 3 seconds,,,")
            os.sleep(3)
        end

        if insufficientPowerProductionCount == 5 then
            print("insufficient production count has been reached. Stopping operation.")
            terminateScript = 1
            break
        end
        print("energy production sustainable")
    end
end

-- calculates the load on the reactor by comparing the buffer value at two different points of time
function energyLoad ()
    local energyStored1, energyStored2, load
    reactor.setActive(false)
    while reactor.getEnergyProducedLastTick() > 0 do
        captureTerminationKey("x")
        if terminateScript == 1 then
            break
        end

        print("reactor still producing power. Load sample cannot be taken")
        os.sleep(0.8)
    end
    energyStored1 = reactor.getEnergyStored()

    os.startTimer(1)
    os.pullEvent("timer")

    energyStored2 = reactor.getEnergyStored()
    reactor.setActive(true)

    load = energyStored1 - energyStored2
    load = load / 20

    return load
end

-- uses sampling of energy produced to determin a formula for the power production decay curve.
function decayCurve ()
    local dataset_, iteration
    dataset_ = {}
    iteration = 0
    
    reactor.setActive(false)
    
    while reactor.getEnergyProducedLastTick() > 0 do
        captureTerminationKey("x")
        if terminateScript == 1 then
            break
        end
        
        dataset_[iteration] = reactor.getEnergyProducedLastTick()

        iteration = iteration + 1

        os.sleep(0.2)

    end
    
    reactor.setActive(true)
    
    return dataset_

end

-- as the name implies it is used to export a table of values to document
function exportTableToFile (filename, filetype, data)
    file = io.open("scripts/cc-extreamereactor-autotune/"..filename.."."..filetype, "a+")

    io.input(file)
    io.output(file)

    for key,value in pairs(data) do
        -- print(key, value)
        io.write(tostring(key) .. " " .. tostring(value) .. ",")
    end

    io.close(file)
end


-- checks if computer is connected to reactor. stops script if not
if reactor == nil then 
    
    print("Not Connected to Reactor, Exiting program.")
    connected = false

-- if the computer reactor wrap returns anything other then "nil" it is connected and the main script is ran
else

    --[[
        sets all control rods insertion to the default value of 0. 
        this gives the reactor the highest chance of the reactor being able to produce enough power for the load
    --]]
    print("seting all control rods to 0 insertion")
    reactor.setAllControlRodLevels(ControlRodLvl)

    -- checks if the reactor is active, if not it activates it
    if reactor.getActive() == false then
        reactor.setActive(true)
    end

    -- main loop
    while(connected) do
        -- catches escape key to escape the loop, and 
        captureTerminationKey("x")
        if terminateScript == 1 then
            break
        end

        -- charges the buffer to the target buffer value befor any other block can run to ensure their is enough power for any tests
        print("charging buffer")
        chargebufferToTarget()
        print("buffer target reached")
        

        -- load = energyLoad()
        -- print(load)

        -- print("letting reactor build back to buffer target")
        -- os.sleep(5)
        dataset = decayCurve()
        exportTableToFile("dataset", "csv", dataset)  -- exports the data collected from the decay curve function to an external csv file. (mostly for human interprutation)

    end
end

reactor.setActive(false) -- deactives reactor as to not waste fuel
print("script stopped.")