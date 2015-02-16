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


Template.hero.helpers
  goldPerDps: -> @getUpgradeCost() / @getDpsDiff(1)

Template.hero.events
  'input .hero-level': (event) ->
    @level = event.target.valueAsNumber

Template.skillbox.events
  'click .skill-box': (event) ->
    @isActive = event.target.checked

###
Template.hero.rendered = ->
  hero = @data
  TT.vm.heroes.push(new ViewModel(this.data).extend(
    nextLevelDpsDiff: -> TT.numberFormat(hero.getDps(hero.level + 1) - hero.getDps())
    goldPerDps: ->
      TT.numberFormat(hero.getUpgradeCost() / (hero.getDps(hero.level + 1) - hero.getDps()))
  ).bind @)

Template.skillbox.rendered = ->
  new ViewModel(
    skill: @data
    isActive: -> @skill().isActive
  ).bind @

Template.artifact.rendered = ->
  artifact = @data
  TT.vm.artifacts.push(new ViewModel(
    getBonus: -> artifact.getBonus()
    getDamage: -> artifact.getDamage()
    level: -> artifact.level
  ).bind @)
###
