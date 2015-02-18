makeLink = ->
  parts = ["#"]
  for hero in TapTitans.Heroes
    parts.push(TT.encode(hero.level))
  parts.push(TT.encode(TapTitans.Player.level))
  parts.push(TT.encode(TapTitans.Player.taps))
  for artifact in TapTitans.Artifacts
    parts.push(TT.encode(artifact.level))

  # Strip off trailing zeroes, but only remove them in groups of two
  return parts.join('').replace(/(!!)+$/, '')

readLink = ->
  data = location.hash.substr(1) # Drop the leading #
  for hero in TapTitans.Heroes
    hero.level = TT.decode(data)
    data = data.substr(2)
  TapTitans.Player.level = TT.decode(data)
  data = data.substr(2)
  TapTitans.Player.taps = TT.decode(data)
  data = data.substr(2)
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

valGrabber = (name, deflt, how='valueAsNumber') ->
  return (event) ->
    if _.isEmpty(event.target.value)
      event.target.value = deflt
      event.target.select()
    @[name] = event.target[how]

levelEvents =
  'click tr, click input': (event) ->
    if document.activeElement == document.body
      $(event.currentTarget).find('.level').focus()
  'input .level': valGrabber('level', 0)
  'focus input': (event) ->
    $(event.target).parents('tr').addClass('focus')
  'blur input': (event) ->
    $(event.target).parents('tr').removeClass('focus')

Template.hero.events levelEvents

Template.skillbox.helpers
  isLocked: -> @owner.level < @reqLevel
Template.skillbox.events
  'click .skill-box': (event) ->
    @setActive(event.target.checked)

Template.artifact.events levelEvents
Template.artifact.helpers
  damageDiff: ->
    return @getDamage(@level+1) - @getDamage()

Template.artifacts.helpers
  totalArtifactAllDamage: -> TapTitans.getTotalBonus("ArtifactAllDamage")

Template.player.events levelEvents
Template.player.events
  'input .taps': valGrabber('taps', 0)
  'input .name': valGrabber('name', 'Lightning Blade', 'value')
