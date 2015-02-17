TapTitans = {}

# Constants
heroEvolveLevel = 1001
evolveCostMultiplier = 10
heroUpgradeBase = 1.075
levelIneffiency = 0.904
heroInefficiency = 0.019
heroInefficiencySlowDown = 15
damageScaleDown = 0.1
artifactCostFactor = 1.35

bossFactor = [2, 4, 6, 7, 10]


class Artifact extends ReactiveObject
  constructor: (props) ->
    props.level = 0
    super(props)

  getBonus: (lvl=@level) ->
    return @bonusPerLevel * lvl

  getDamage: (lvl=@level) ->
    # Level 1 has double the damage boost
    return @damagePerLevel + @damagePerLevel * lvl

  getUpgradeCost: (lvl=@level) ->
    if lvl == 0
      return TapTitans.nextArtifactCost()
    return Math.round(@costFactor * (lvl + 1)**@costExpo)


class Hero extends ReactiveObject
  constructor: (props) ->
    props.level = 0
    props.skills = (new Skill(skill, @) for skill in props.skills)
    super(props)

  getBaseCost: (lvl=@level) ->
    if lvl >= (heroEvolveLevel - 1)
      return @cost * evolveCostMultiplier
    return @cost

  getUpgradeCost: (lvl=@level) ->
    return Math.ceil(
      @getBaseCost(lvl) * heroUpgradeBase**lvl *
      (1 + TapTitans.getTotalBonus("AllUpgradeCost"))
    )

  getTotalUpgradeCost: (desiredLevel) ->
    return _.sum (@getUpgradeCost(lvl) for lvl in [@level...desiredLevel])

  isEvolved: (lvl=@level) ->
    return lvl >= heroEvolveLevel

  _accumulateBonuses: (bonusType) ->
    return _.sum ((
      if skill.isActive and skill.bonusType == bonusType
        skill.magnitude
      else 0
    ) for skill in @skills)

  getSelfDamageBoost: -> @_accumulateBonuses("ThisHeroDamage")

  getDps: (lvl=@level) ->
    if @isEvolved(lvl)
      num3 = levelIneffiency**(lvl - heroEvolveLevel) *
        (1 - (heroInefficiency * heroInefficiencySlowDown))**(@heroId + 30)
      num4 = @getUpgradeCost(lvl - 1) *
        (heroUpgradeBase**(lvl - (heroEvolveLevel - 1)) - 1) /
          (heroUpgradeBase - 1) * num3 * damageScaleDown
    else
      num3 = levelIneffiency**(lvl - 1) *
        (1 - (heroInefficiency * Math.min(@heroId, heroInefficiencySlowDown)))**@heroId
      num4 = @getUpgradeCost(lvl - 1) *
        (heroUpgradeBase**lvl - 1) / (heroUpgradeBase - 1) * num3 * damageScaleDown
    return Math.floor(num4 * (TapTitans.allDamageFactor + @getSelfDamageBoost()) *
      TapTitans.artifactDamageFactor)

  getDpsDiff: (levelDelta=1) ->
    return @getDps(@level + levelDelta) - @getDps()


class Skill extends ReactiveObject
  constructor: (props, owner) ->
    props._isActive = false
    props.owner = owner
    super(props)

  isActive: ->
    if @owner.level > @reqLevel
      return true
    if @owner.level < @reqLevel
      return false
    return @_isActive

  setActive: (val) -> @_isActive = val

  isLocked: -> @owner.level != @reqLevel

  getUpgradeCost: ->
    num = @owner.getTotalUpgradeCost(@reqLevel)
    num2 = 0
    for skill2 in @owner.skills
      if not skill2.isActive
        num2 += @owner.getUpgradeCost(skill2.reqLevel) * 5
      if skill2.name == @name
        break
    return num + num2

  getBonus: ->
    return @magnitude


class Player extends Hero
  constructor: (props) ->
    props.taps = 5
    super(props)
    @level = 1

  ###
  getDps: (lvl=@level) ->
    # Is this different than for heros?
    return super(lvl)
  ###


###
TT.heroUpgradeBase = 1.075
TT.dMGScaleDown = 0.1
TT.passiveSkillCostMultiplier = 5
TT.currentAllHeroDPS = 0
TT.StatBonusAllDamage = 0
TT.StatBonusGoldAll = 0
TT.CritDamagePassive = 10
TT.TapDamageFromDPS = 0
TT.CritChance = 0.02
TT.TapDamagePassive = 0
TT.artifactBonusDamage = 0
###

class Game extends ReactiveObject
  constructor: ->
    props =
      allDamageFactor: 1
      artifactDamageFactor: 1
      stage: 1
    super(props)

    @Player =  new Player(Data.Player)
    @Artifacts = (new Artifact(artifact) for artifact in Data.ArtifactInfo)
    @Heroes = (new Hero(hero) for hero in Data.HeroInfo)

    @Artifact =
      DarkCloakOfLife: @Artifacts[2]
      DeathSeeker: @Artifacts[3]
      HerosThrust: @Artifacts[16]
      FuturesFortune: @Artifacts[19]
      RingOfWonderousCharm: @Artifacts[23]
      TinctureOfTheMaker: @Artifacts[25]
      DrunkenHammer: @Artifacts[28]

    items = @Artifacts[...]
    for hero in @Heroes
      for skill in hero.skills
        items.push(skill)

    @_bonus = {}
    for item in items
      if item.bonusType not of @_bonus
        @_bonus[item.bonusType] = []
      @_bonus[item.bonusType].push(item)

  getTotalBonus: (type) ->
    return _.sum(item.getBonus() for item in @_bonus[type])

  nextArtifactCost: ->
    num = 1 + _.sum ((artifact.level > 0) for artifact in @Artifacts)
    return Math.floor(num * artifactCostFactor**num)

  getMonsterHealth: (stage=@stage) ->
    return 18.5 * 1.57**Math.min(stage, 150) * 1.17**Math.max(stage-150, 0)

  getBossHealth: (stage=@stage) ->
    return @getMonsterHealth(stage) * bossFactor[(stage-1)%5] *
      (1 + @getTotalBonus("BossLife"))


TapTitans = new Game()
