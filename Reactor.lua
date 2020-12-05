local BufferMax = 10000000
local BufferMinThreshold = .2
local BufferMaxThreshold = 0.95

local reactor
reactor = peripheral.wrap("back")
while(true) do
	local currentEnergy = reactor.getEnergyStored() / BufferMax
	if (currentEnergy < BufferMinThreshold) then
		reactor.setActive(true)
	elseif(currentEnergy > BufferMaxThreshold) then
		reactor.setActive(false)
	end
	sleep(5)
end