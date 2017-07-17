require '/scripts/power.lua'

function init()
  power.init()
  object.setInteractive(true)
end

function onInteraction()
  object.say(power.getTotalEnergy()..'\n'..sb.printJson(storage.entitylist))
end