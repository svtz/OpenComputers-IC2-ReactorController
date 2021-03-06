local serializer = require('serialization')
local shell = require('shell')
local sides = require('sides')

local config = {
    allowMaxDamage = {
        ['gregtech:gt.Quad_Thoriumcell'] = 100,
        ['IC2:reactorVentGold'] = 100
    },
    fuelSlots = {
        [11] = 'gregtech:gt.Quad_Thoriumcell',
        [14] = 'gregtech:gt.Quad_Thoriumcell',
        [17] = 'gregtech:gt.Quad_Thoriumcell',
        [38] = 'gregtech:gt.Quad_Thoriumcell',
        [41] = 'gregtech:gt.Quad_Thoriumcell',
        [44] = 'gregtech:gt.Quad_Thoriumcell'
    },
    reactorLocationSide = sides.west,
    interfaceLocationSide = sides.bottom,
    redstoneOutputSide = sides.back,
    activeZoneStartSlot = 1,
    activeZoneEndSlot = 54
}


local path = shell.getWorkingDirectory() .. '/controller.cfg'
local output = io.open(path, 'w')
local content = serializer.serialize(config, 100)
output:write(content)
output:close()

print('Complete.')