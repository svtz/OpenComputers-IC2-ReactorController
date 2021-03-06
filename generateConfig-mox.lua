local serializer = require('serialization')
local shell = require('shell')
local sides = require('sides')

local config = {
    allowMaxDamage = {
        ['gregtech:gt.reactorMOXQuad'] = 100,
        ['IC2:reactorVentGold'] = 300
    },
    fuelSlots = {
        [11] = 'gregtech:gt.reactorMOXQuad',
        [14] = 'gregtech:gt.reactorMOXQuad',
        [17] = 'gregtech:gt.reactorMOXQuad',
        [38] = 'gregtech:gt.reactorMOXQuad',
        [41] = 'gregtech:gt.reactorMOXQuad',
        [44] = 'gregtech:gt.reactorMOXQuad'
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