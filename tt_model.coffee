class Artifact
  constructor: (props) ->
    {@name, @maxLevel, @bonusType, @bonusPerLevel, @damageBonus, @costCoEff, @costExpo, @artifactID} = props
    @level = 0
    #@currentBonus = @bonusPerLevel

  getBonus: (lvl=@level) ->
    return @bonusPerLevel * lvl


heroEvolveLevel = 1001
evolveCostMultiplier = 10
heroUpgradeBase = 1.075

class Hero
  constructor: (props) ->
    {@name, @cost, @heroID, @skills} = props
    @level = 0

    @skills = (new Skill(skill) for skill in @skills)
    for skill in @skills
      skill.owner = @

  getBaseCost: (lvl=@level) ->
    if lvl >= (heroEvolveLevel - 1)
      return @cost * evolveCostMultiplier
    return @cost

  getUpgradeCost: (lvl=@level) ->
    return Math.ceil(
      @getBaseCost(lvl) * heroUpgradeBase**lvl *
      (1 + TT.objs.Artifact.RingOfWonderousCharm.getBonus())
    )


class Skill
  constructor: (props) ->
    {@name, @bonusType, @magnitude, @reqLevel, @cost, @skillID} = props
    @isActive = false


###
TT.levelIneffiency = 0.904
TT.heroInefficiency = 0.019
TT.heroInefficiencySlowDown = 15
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


TT.objs =
  Artifacts: (new Artifact(artifact) for artifact in TT.ArtifactInfo)
  Heroes: (new Hero(hero) for hero in TT.HeroInfo)

TT.objs.Artifact =
  DeathSeeker: TT.objs.Artifacts[3]
  HerosThrust: TT.objs.Artifacts[16]
  FuturesFortune: TT.objs.Artifacts[19]
  RingOfWonderousCharm: TT.objs.Artifacts[23]
  TinctureOfTheMaker: TT.objs.Artifacts[25]
  DrunkenHammer: TT.objs.Artifacts[28]
