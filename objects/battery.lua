require '/scripts/power.lua'

function init()
  power.init()
  object.setInteractive(true)
  power.setPower(5)
  power.setMaxEnergy(100)
end

function onInteraction()
    object.say(storage.storedenergy+storage.energy)
end