_bonusDescriptions =
  AllBossDamage: "Increase all damage on Boss"
  AllDamage: "Increase ALL damage"
  AllUpgradeCost: "TODO: AllUpgradeCost"
  ArtifactDamageBoost: "Increase all DPS"
  BossLife: "TODO: BossLife"
  BossTime: "TODO: BossTime"
  CritChance: "Increase critical chance"
  CritDamageArtifact: "Increase critical damage"
  CritDamagePassive: "Increase critical damage"
  Gold10xChance: "Increase chance for 10x gold"
  GoldAll: "Increase gold droppped amount"
  GoldBoss: "Increase gold from Bosses"
  GoldMinion: "TODO: GoldMinion"
  GoldOnline: "Increase gold while playing"
  GoldTreasureArtifact: "Increase gold treasure box chance<br><small>(Increase gold from Chesterson)</small>"
  GoldTreasurePassive: "Increase treasure chest gold amount"
  HeroDeathChance: "TODO: HeroDeathChance"
  MonstersRequiredToAdvance: "Decrease monsters per stage"
  PrestigeRelic: "Increase relics from Prestige"
  ReviveTime: "TODO: ReviveTime"
  SkillTapGoldDuration: "TODO: SkillTapGoldDuration"
  SkillBurstDamageCD: "Decrease Heavenly Strike cooldown"
  SkillConstantDamageCD: "Decrease Shadow Clone cooldown"
  SkillConstantDamageDuration: "Increase Shadow Clone duration"
  SkillCriticalChanceBoostCD: "TODO: SkillCriticalChanceBoostCD"
  SkillCriticalChanceBoostDuration: "TODO: SkillCriticalChanceBoostDuration"
  SkillHeroesAttackSpeedIncreaseCD: "TODO: SkillHeroesAttackSpeedIncreaseCD"
  SkillHeroesAttackSpeedIncreaseDuration: "TODO: SkillHeroesAttackSpeedIncreaseDuration"
  SkillTapDamageIncreaseCD: "Decrease Berserker Rage cooldown"
  SkillTapDamageIncreaseDuration: "TODO: SkillTapDamageIncreaseDuration"
  SkillTapGoldCD: "Decrease Hand of Midas cooldown"
  TapDamageArtifact: "Increase tap damage"
  TapDamageFromDPS: "Increase tap damage by %s of total DPS"
  TapDamagePassive: "Increase tap damage"
  ThisHeroDamage: "Increase this hero's damage"
  TreasureChance: "Increase treasure box chance<br><small>(Increase chance of Chesterson)</small>"

_fmtBonus = (fmt, val) ->
  if val? and fmt?.indexOf("%s") == -1
    fmt += " by %s"
  return sprintf(fmt, val)


makeLink = ->
  parts = ["#"]
  for hero in TapTitans.Heroes
    parts.push(Util.encode(hero.level))
  parts.push(Util.encode(TapTitans.Player.level))
  parts.push(Util.encode(TapTitans.Player.taps))
  for artifact in TapTitans.Artifacts
    parts.push(Util.encode(artifact.level))

  # Strip off trailing zeroes, but only remove them in groups of two
  return parts.join('').replace(/(!!)+$/, '')

readLink = ->
  data = location.hash.substr(1) # Drop the leading #
  for hero in TapTitans.Heroes
    hero.level = Util.decode(data)
    data = data.substr(2)
  TapTitans.Player.level = Util.decode(data)
  data = data.substr(2)
  TapTitans.Player.taps = Util.decode(data)
  data = data.substr(2)
  for artifact in TapTitans.Artifacts
    artifact.level = Util.decode(data)
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
  isLocked: -> @owner.evoLevel() < @reqLevel
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


helpers =
  TapTitans: TapTitans
  asPercent: Util.formatPercent
  numberFormat: Util.formatTTNumber
  bonusDescription: (bonusType, magnitude=null) ->
    if typeof magnitude == "number"
      magnitude = Util.formatPercent(magnitude, false)
    else
      magnitude = null
    _fmtBonus(_bonusDescriptions[bonusType], magnitude)

for name, thing of helpers
  Template.registerHelper(name, thing)
