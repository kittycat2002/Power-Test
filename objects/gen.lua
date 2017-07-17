require '/scripts/power.lua'

function init()
  power.init()
  object.setInteractive(true)
end

function onInteraction()
  if storage.on then
    power.setPower()
	storage.on = false
	object.say('No longer outputting power.')
  else
    power.setPower(5)
	storage.on = true
	object.say('Now outputting 5 watts of power.')
  end
end