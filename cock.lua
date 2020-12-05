local reactor = peripheral.wrap("back")

local function EnergyProducedSeconds()
     local BufferLoad, Produced, BufferLoadOne, BufferLoadTwo
     Produced = reactor.getEnergyProducedLastTick()
     BufferLoadOne = reactor.getEnergyStored()
   
    function BufferLoadTwo()
        reactor.setActive(false)
        sleep(10)
        BufferLoadTwo = reactor.getEnergyStored()
        reactor.setActive(true)
        return BufferLoadTwo
    end
    
    BufferLoad = (BufferLoadOne - BufferLoadTwo()) / 10 / 20
    EnergyProducedSeconds = Produced - BufferLoad
    sleep(1)
    return EnergyProducedSeconds
end
print(EnergyProducedSeconds())