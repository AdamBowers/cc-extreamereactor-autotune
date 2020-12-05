-- declaring local variables which are really just working as global variables but fuck off.
local reactor = peripheral.wrap("back")
local reactorBufferSize, reactorBufferTarget, reactorControlRodLvl, reactorBufferStore
local timeout, connected, energyProducedLastTick_, terminateScript, energyProductionTarget
local insufficientPowerProductionCount, load

-- default values to some common variables
reactorBufferSize = 10000000
reactorBufferTarget = 9900000
reactorBufferTargetTolerance = 0.001
ControlRodLvl = 0
energyProducedLastTick_ = 0
terminateScript = 0
energyProductionTarget = math.pow(2, 20)
insufficientPowerProductionCount = 0

connected = true

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

function decayCurve ()
    print("fuck you cunt!")
end


if reactor == nil then 
    
    print("Not Connected to Reactor, Exiting program.")
    connected = false

else

    print("seting all control rods to 0 insertion")
    reactor.setAllControlRodLevels(ControlRodLvl)

    if reactor.getActive() == false then
        reactor.setActive(true)
    end

    -- main loop
    while(connected) do
        
        captureTerminationKey("x")
        if terminateScript == 1 then
            break
        end

        print("charging buffer")
        chargebufferToTarget()
        print("buffer target reached")
        

        load = energyLoad()
        print(load)

        print("letting reactor build back to buffer target")
        os.sleep(5)

    end

    reactor.setActive(false)
    print("reactor stopped.")

end




