//SystemBus.cpp

#include "SystemBus.h"
#include "SystemAddressMap.h"
#include <iostream>

SystemBus::SystemBus(MainMemory& mainMemory, PeripheralDevicesCore& peripheralDevices) :
	unmappedAccesses(0),
	mainMemory_(mainMemory),
	peripheralDevices_(peripheralDevices)
{
}

void SystemBus::attachEngine(unsigned int i, PhysicalMemoryInterface* engine)
{
	if (engines_.size() <= i)
		engines_.resize(i + 1, nullptr);
	engines_[i] = engine;
}

void SystemBus::access(const PhysicalMemoryRequest& request, PhysicalMemoryResponse& response)
{
	switch (SystemAddressMap::decode(request.physicalAddress))
	{
		case SystemAddressMap::Target::MAIN_MEMORY:
			mainMemory_.access(request, response);
			break;
		case SystemAddressMap::Target::PERIPHERAL_DEVICES:
			peripheralDevices_.access(request, response);
			break;
		case SystemAddressMap::Target::APARA_ENGINE:
		{
			int e = SystemAddressMap::aparaEngineAt(request.physicalAddress);
			if (e >= 0 && (unsigned int) e < engines_.size() && engines_[e])
			{
				engines_[e]->access(request, response);
				break;
			}
		}
		//fall through: no engine attached
		case SystemAddressMap::Target::UNMAPPED:
		default:
			unmappedAccesses++;
			std::cerr << "\nWarning: SystemBus: access to unmapped physical address 0x"
			          << std::hex << request.physicalAddress << std::dec
			          << (request.accessType == PhysicalAccessType::READ ? ", read as 0" : ", write ignored");
			response.valid    = true;
			response.mae      = false;
			response.readData = 0;
			break;
	}
}
