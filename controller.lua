local function loadConfig()
  local shell = require('shell')
  local path = shell.getWorkingDirectory() .. '/controller.cfg'
  local cfgFile = io.open(path)
  if (cfgFile == nil) then
    error('Config not found: ' .. path)
  end
  local cfgContent = cfgFile:read("*all")
  cfgFile:close()

  local serializer = require('serialization')
  return assert(serializer.unserialize(cfgContent))
end

--initialization
local config = loadConfig()
local component = require('component')
local sides = require('sides')
local transposer = assert(component.transposer)
local redstone = assert(component.redstone)

-- check functions
local function checkDamage()
  local invSize = transposer.getInventorySize(config.reactorLocationSide)
  if (invSize == nil) or (invSize < config.activeZoneEndSlot) then
    return false, 'Invalid reactor inventory size'
  end
  for i = config.activeZoneStartSlot, config.activeZoneEndSlot do
    local stack = transposer.getStackInSlot(config.reactorLocationSide, i)
    if (stack == nil) and (config.fuelSlots[i] == nil) then -- fuel slot can be empty
      return false, 'Slot ' .. tostring(i) .. ' is empty'
    end
    if not (stack == nil) then
      local stackName = assert(stack.name)
      local maxDamage = config.allowMaxDamage[stackName]
      if (maxDamage == nil) then
        maxDamage = 0
      end
      local actualDamage = assert(stack.damage)
      if (actualDamage > maxDamage) then
        return false, 'Component ' .. stackName .. ' in slot #' .. tostring(i) .. ' is overheated (damageValue = ' .. tostring(actualDamage) .. ')'
      end
    end
    os.sleep(0.1)
  end

  return true, 'Ok'
end

local function reloadFuelIfNeeded()
  local function findItemInInterface(name)
    local invSize = transposer.getInventorySize(config.interfaceLocationSide)
    for i = 1, invSize do
      local stack = transposer.getStackInSlot(config.interfaceLocationSide, i)
      if (not (stack == nil)) and (stack.name == name) then
        return i
      end
    end
    return nil
  end
  local function load(name, targetSlot)
    local interfaceSlot = findItemInInterface(name)
    if (interfaceSlot == nil) then
      return false, 'Out of fuel'
    end
    local status = transposer.transferItem(config.interfaceLocationSide, config.reactorLocationSide, 1, interfaceSlot, targetSlot)
    assert(status == true)
    return true, 'Ok'
  end
  local function unload(fromSlot)
    local status = transposer.transferItem(config.reactorLocationSide, config.interfaceLocationSide, 1, fromSlot)
    assert(status == true)
    return true, 'Ok'
  end

  -- cycle through fuel slots
  local slotsRequireFuel = {}
  for i,name in pairs(config.fuelSlots) do
    local stack = transposer.getStackInSlot(config.reactorLocationSide, i)
    local status, msg
    if (not (stack == nil)) and (not (stack.name == name)) then
      assert(stack.size == 1)
      status, msg = unload(i)
      if (not status) then
        return false, msg
      end
      stack = nil
    end
    if (stack == nil) then
      slotsRequireFuel[i] = name
    end
  end
  -- loading fuel
  for i,name in pairs(slotsRequireFuel) do
    local status, msg = load(name, i)
    if (not status) then
      return false, msg
    end
  end

  return true, 'Ok'
end

--redstone control
local function disableReactor()
  local currentOut = redstone.getOutput(config.redstoneOutputSide)
  if not (currentOut == 0) then
    print('Stopping reactor...')
    redstone.setOutput(config.redstoneOutputSide, 0)
  end
end
local function enableReactor()
  local currentOut = redstone.getOutput(config.redstoneOutputSide)
  if not (currentOut == 255) then
    print('Starting reactor...')
    redstone.setOutput(config.redstoneOutputSide, 255)
  else
    print(os.date('%X') .. ': health check OK, running')
  end
end

--main loop
while (true) do
  local ok, msg
  local status, pcallMsg
  
  status, pcallMsg = pcall(function() ok, msg = checkDamage() end)
  if not status then
    print(pcallMsg)
    disableReactor()
    print('Exiting.')
    return
  elseif not ok then
    print(os.date('%X: ') .. msg)
    disableReactor()
  else
    status, pcallMsg = pcall(function() ok, msg = reloadFuelIfNeeded() end)
    if not status then
      print(pcallMsg)
      disableReactor()
      print('Exiting.')
      return
    elseif not ok then
      print(os.date('%X: ') .. msg)
      disableReactor()
    else
      enableReactor()
    end
  end
  os.sleep(5)
end

