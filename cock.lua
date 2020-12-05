local reactor, EnergyProducedSeconds, PowerDeccel, PowerCurrent, PowerCount
local BufferLoad, Produced, BufferLoadOne, BufferLoadTwo

reactor = peripheral.wrap("back")
PowerCurrent = reactor.getEnergyProducedLastTick()
PowerCount = 0

function EnergyProducedSeconds()
     Produced = reactor.getEnergyProducedLastTick()
     BufferLoadOne = reactor.getEnergyStored()
   
    function BufferLoadTwo()
        reactor.setActive(false)
        sleep(11)
        BufferLoadTwo = reactor.getEnergyStored()
        reactor.setActive(true)
        return BufferLoadTwo
    end
   function PowerDeccel() 
        while(true) do 
        if PowerCurrent > 0 then 
            PowerCount + 1
    
    end
    
    BufferLoad = (BufferLoadOne - BufferLoadTwo())
    EnergyProducedSeconds = Produced - BufferLoad
    sleep(1)
    return EnergyProducedSeconds
end
print(EnergyProducedSeconds())