local reactor, PowerCurrent, PowerCount
reactor = peripheral.wrap("back")
PowerCurrent = reactor.getEnergyProducedLastTick()

function PowerCount()
    reactor.setActive(false)
    while PowerCurrent > 0 do
            PowerCount() = PowerCount + 1
            sleep(1)
        return PowerCount
    end
end
sleep(1)   
print(PowerCount())