makeLink = ->
  parts = ["#"]
  for hero in TapTitans.Heroes
    parts.push(TT.encode(hero.level))
  #parts.push(TT.encode(player.level))
  for artifact in TapTitans.Artifacts
    parts.push(TT.encode(artifact.level))

  # Strip off trailing zeroes, but only remove them in groups of two
  return parts.join('').replace(/(!!)+$/, '')

readLink = ->
  data = location.hash.substr(1) # Drop the leading #
  for hero in TapTitans.Heroes
    hero.level = TT.decode(data)
    data = data.substr(2)
  # Player?
  for artifact in TapTitans.Artifacts
    artifact.level = TT.decode(data)
    data = data.substr(2)

Meteor.startup ->
  readLink()

Template.body.helpers
  makeLink: makeLink

heroHelpers =
  goldPerDps: -> @getUpgradeCost() / @getDpsDiff()

Template.hero.helpers heroHelpers
Template.player.helpers = heroHelpers


levelEvents =
  'input .level': (event) ->
    @level = event.target.valueAsNumber
  'focus input': (event) ->
    $(event.target).parents('tr').addClass('focus')
  'blur input': (event) ->
    $(event.target).parents('tr').removeClass('focus')

Template.hero.events levelEvents

Template.skillbox.events
  'click .skill-box': (event) ->
    @setActive(event.target.checked)

Template.artifact.helpers
  index: -> @artifactId.substr(8)

Template.artifact.events levelEvents

Template.player.events levelEvents
Template.player.events
  'input .taps': (event) ->
    @taps = event.target.valueAsNumber
  'input .name': (event) ->
    @name = event.target.value
