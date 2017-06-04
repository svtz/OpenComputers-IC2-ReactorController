local sides = require('sides')
local component = require('component')
local shell = require('shell')

local tr = component.transposer
if (tr == nil) then
  error('Transposer not found')
end


local output = io.open(shell.getWorkingDirectory() .. '/reactorInventory.txt', 'w')
local reactorLocation = sides.west
local invSize = tr.getInventorySize(reactorLocation)
for i = 1, invSize do
  local stack = tr.getStackInSlot(reactorLocation, i)
  if not (stack == nil) then
    output:write('===slot #' .. tostring(i) .. '\n')
    output:write('name = ' .. tostring(stack.name) .. '\n')
    output:write('label = ' .. tostring(stack.label) .. '\n')
    output:write('damage = ' .. tostring(stack.damage) .. '\n')
    output:write('\n')
  end
end
print('Complete.')
output:close()