require '/scripts/power.lua'

function update(dt)
  if (storage.fueltime or 0) > 0 then
    storage.fueltime = math.max((storage.fueltime or 0) - dt,0)
	object.say(storage.fueltime)
  end
  if not storage.fueltime or storage.fueltime == 0 then
    power.setPower()
    item = world.containerItemAt(entity.id(),0)
	if item then
	  itemlist = config.getParameter('generatorconfig')
	  for key,value in pairs(itemlist) do
	    if item.name == key then
	      world.containerConsumeAt(entity.id(),0,1)
	      storage.fueltime = value.time
		  power.setPower(value.power)
		end
	  end
	end
  end
  power.update(dt)
end