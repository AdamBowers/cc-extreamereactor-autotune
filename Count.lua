local reactor, PowerCurrent, PowerCount
reactor = peripheral.wrap("back")

function PowerCount ()
    PowerCount = 0 -- explicit decleration of powercounts starting value. I dont know how lua processes nil + 1
    reactor.setActive(false)
    while reactor.getEnergyProducedLastTick() > 0 do
            PowerCount = PowerCount + 1 -- you dont set a function equal to a value
            sleep(1)  -- moved return outside of while loop. it'll end the function before it finishes is inside
    end
    return PowerCount
end
sleep(1)   
print(PowerCount())
reactor.setActive(true)