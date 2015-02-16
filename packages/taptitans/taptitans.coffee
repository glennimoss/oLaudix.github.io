TapTitans = {}

#Something better please
Game =
  allDamageFactor: 1
  artifactDamageFactor: 1
  nextArtifactCost: () ->
    num = _.reduce TapTitans.Artifacts,
      (n, artifact) -> n + (artifact.level > 0)
      1

    return Math.floor(num * 1.35**num)


class Artifact
  constructor: (props) ->
    {@name, @maxLevel, @bonusType, @bonusPerLevel, @damageBoost, @costFactor, @costExpo, @artifactID} = props
    @level = 0
    #@currentBonus = @bonusPerLevel

  getBonus: (lvl=@level) ->
    return @bonusPerLevel * lvl

  getDamage: (lvl=@level) ->
    return @damageBoost * lvl

  getUpgradeCost: (lvl=@level) ->
    if lvl == 0
      return Game.nextArtifactCost()
    return Math.round(@costFactor * (lvl + 1)**@costExpo)

heroEvolveLevel = 1001
evolveCostMultiplier = 10
heroUpgradeBase = 1.075
levelIneffiency = 0.904
heroInefficiency = 0.019
heroInefficiencySlowDown = 15
damageScaleDown = 0.1

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
      (1 + TapTitans.Artifact.RingOfWonderousCharm.getBonus())
    )

  isEvolved: (lvl=@level) ->
    return lvl >= heroEvolveLevel

  _accumulateBonuses: (bonusType) ->
    return _.reduce @skills, ((n, skill) -> n + (
      if skill.isActive and skill.bonusType == bonusType
        skill.magnitude
      else 0
    )), 0

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
    return Math.floor(num4 * (Game.allDamageFactor + @getSelfDamageBoost()) *
      Game.artifactDamageFactor)

  getDpsDiff: (levelDelta=1) ->
    return @getDps(@level + levelDelta) - @getDps()

class Skill extends ReactiveObject
  constructor: (props, @owner) ->
    props.isActive = false
    super(props)


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


TapTitans =
  Artifacts: (new Artifact(artifact) for artifact in Data.ArtifactInfo)
  Heroes: (new Hero(hero) for hero in Data.HeroInfo)

TapTitans.Artifact =
  DeathSeeker: TapTitans.Artifacts[3]
  HerosThrust: TapTitans.Artifacts[16]
  FuturesFortune: TapTitans.Artifacts[19]
  RingOfWonderousCharm: TapTitans.Artifacts[23]
  TinctureOfTheMaker: TapTitans.Artifacts[25]
  DrunkenHammer: TapTitans.Artifacts[28]
