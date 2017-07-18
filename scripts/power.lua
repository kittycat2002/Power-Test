power = {}

function power.init()
  time = 0.5
  message.setHandler('isPower', isPower)
  message.setHandler('connect', onNodeConnectionChange)
  message.setHandler('update', updateList)
  message.setHandler('getenergy', power.getEnergy)
  message.setHandler('getstorageleft', power.getStorageLeft)
  message.setHandler('recievepower', power.recievePower)
  message.setHandler('remove', power.remove)
end

function init()
  power.init()
end

function power.update(dt)
  if time > 0 then
    time = time - dt
  else
    if config.getParameter('powertype') == 'battery' then
      storage.storedenergy = (storage.storedenergy or 0) + (storage.energy or 0)
    else
      power.sendPowerToBatteries()
    end
    if storage.power and storage.power > 0 then
      storage.energy = storage.power * dt
	  if config.getParameter('powertype') == 'battery' then
	    storage.energy = math.min(storage.energy,storage.storedenergy)
        storage.storedenergy = storage.storedenergy - storage.energy
      end
    else
      storage.energy = 0
    end
  end
end

function update(dt)
  power.update(dt)
end

function power.getStorageLeft()
  return (storage.maxenergy or 0) - (storage.storedenergy or 0) - (storage.energy or 0)
end

function power.getStoredEnergy()
  return storage.storedenergy + storage.energy
end

function power.remove(amount2,_,amount)
  if not amount then
    amount = amount2
  end
  storage.energy = storage.energy - amount
end

function power.consume(amount)
  if power.getTotalEnergy() >= amount then
    for i=1,entityListLength() do
	  energy = power.getEnergy(storage.entitylist.all[i])
	  if energy > 0 then
	    energy = math.min(energy,amount)
		world.sendEntityMessage(storage.entitylist.all[i],'remove',energy)
		amount = amount - energy
	  end
	  if amount == 0 then
	    return true
	  end
	end
  else
    return false
  end
end

function power.sendPowerToBatteries()
  if (storage.energy or 0) > 0 then
    entityListLength()
    for key,value in pairs(storage.entitylist.battery) do
      message = world.sendEntityMessage(value,'getstorageleft')
	  while not message:result() do end
      amount = math.min(storage.energy,message:result())
	  storage.energy = storage.energy - amount
	  world.sendEntityMessage(value,'recievepower',amount)
	  if storage.energy == 0 then
	    break
	  end
	end
  end
end

function power.recievePower(_,_,amount)
  storage.storedenergy = storage.storedenergy + amount
end

function power.setMaxEnergy(energy)
  storage.maxenergy = (energy or 0)
end

function power.setPower(power)
storage.power = power or 0
end

function entityListLength()
  if not storage.entitylist then
    if config.getParameter('powertype') == 'battery' then
      storage.entitylist = {battery = {entity.id()},all = {entity.id()}}
	else
	  storage.entitylist = {battery = {},all = {entity.id()}}
	end
  end
  return #storage.entitylist.all
end

function power.getTotalEnergy()
  local energy = 0
  for i=1,entityListLength() do
	energy = energy + power.getEnergy(storage.entitylist.all[i])
  end
  return energy
end

function power.getEnergy(id)
  if not id or id == entity.id() or id == 'getenergy' then
    return storage.energy or 0
  else
    message = world.sendEntityMessage(id,'getenergy')
	while not message:result() do end
	return message:result()
  end
end

function onNodeConnectionChange(_,_,arg)
  if arg then
    entitylist = arg
  else
    if config.getParameter('powertype') == 'battery' then
      entitylist = {battery = {entity.id()},all = {entity.id()}}
	else
	  entitylist = {battery = {},all = {entity.id()}}
	end
  end
  
  for i=0,object.inputNodeCount()-1 do
    if object.isInputNodeConnected(i) then
	  local idlist = object.getInputNodeIds(i)
	  for value in pairs(idlist) do
	    powertype = world.sendEntityMessage(value,'isPower'):result()
	    if powertype then
	      for j=1,#entitylist.all+1 do
		    if j == #entitylist.all+1 then
			  if powertype == 'battery' then
			    table.insert(entitylist.battery,value)
			  end
		      table.insert(entitylist.all,value)
			  message = world.sendEntityMessage(value,'connect',entitylist)
			  while not message:result() do end
			  entitylist = message:result()
		    elseif entitylist.all[j] == value then
		      break
		    end
		  end
		end
	  end
	end
  end
  for i=0,object.inputNodeCount()-1 do
    if object.isOutputNodeConnected(i) then
	  local idlist = object.getOutputNodeIds(i)
	  for value in pairs(idlist) do
	    powertype = world.sendEntityMessage(value,'isPower'):result()
	    if powertype then
	      for j=1,#entitylist.all+1 do
		    if j == #entitylist.all+1 then
			  if powertype == 'battery' then
			    table.insert(entitylist.battery,value)
			  end
		      table.insert(entitylist.all,value)
			  message = world.sendEntityMessage(value,'connect',entitylist)
			  while not message:result() do end
			  entitylist = message:result()
		    elseif entitylist.all[j] == value then
		      break
		    end
		  end
		end
	  end
	end
  end
  if arg then
    return entitylist
  else
    storage.entitylist = entitylist
    for i=2,#entitylist.all do
      world.sendEntityMessage(entitylist.all[i],'update',entitylist)
    end
  end
end

function isPower()
  return config.getParameter('powertype')
end

function updateList(_,_,list)
  storage.entitylist = list
end