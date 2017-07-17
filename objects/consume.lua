require '/scripts/power.lua'

function init()
  power.init()
  object.setInteractive(true)
end

function update(dt)
  power.update(dt)
  test = power.consume(5*dt)
end

function onInteraction()
  object.say((test and 'Successfully consumed power.' or 'Failed to consume power.'))
end