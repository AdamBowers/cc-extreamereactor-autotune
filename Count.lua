local reactor, PowerCurrent, PowerCount
reactor = peripheral.wrap("back")
PowerCurrent = reactor.getEnergyProducedLastTick()
local PowerC = 0

function PowerCount(PowerC)
    
    while true do
        if PowerCurrent > 0 then
            PowerC = PowerC + 1
        elseif PowerCurrent == 0 then
            
        return PowerC
        end
    end
end    
    sleep(1)
print(PowerCount())