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
relicsFirstStage = 75
relicsStagesPerIncrease = 15
relicsAllHeroesBonus = 2

bossFactor = [2, 4, 6, 7, 10]


class Artifact extends ReactiveObject
  constructor: (data) ->
    { @name, @maxLevel, @bonusType, @bonusPerLevel, @damagePerLevel, @costFactor,
      @costExpo, @artifactId
    } = data

    super
      level: 0


  getBonus: (lvl=@level) ->
    return @bonusPerLevel * lvl

  getDamage: (lvl=@level) ->
    if lvl == 0
      return 0
    # Level 1 has double the damage boost
    return ((@damagePerLevel + @damagePerLevel * lvl) *
            (1 + TapTitans.getTotalBonus("ArtifactDamageBoost")))

  getUpgradeCost: (lvl=@level) ->
    if lvl == 0
      return TapTitans.nextArtifactCost()
    return Math.round(@costFactor * (lvl + 1)**@costExpo)


class Hero extends ReactiveObject
  constructor: (data) ->
    {@name, @cost, @heroId} = data

    @skills = []
    if data.skills?.length
      @skills.push(new Skill(data.skills[0], @))
      prevSkill = @skills[0]
      for skill in data.skills[1...]
        newSkill = new Skill(skill, @, prevSkill)
        @skills.push(newSkill)
        prevSkill = newSkill

    super
      level: 0

  getUpgradeCost: (lvl=@level) ->
    cost = @cost
    if lvl >= (heroEvolveLevel - 1)
      cost *= evolveCostMultiplier
    return Math.ceil(cost * heroUpgradeBase**lvl *
      (1 + TapTitans.getTotalBonus("AllUpgradeCost"))
    )

  getTotalUpgradeCost: (desiredLevel) ->
    return _.sum (@getUpgradeCost(lvl) for lvl in [@level...desiredLevel])

  isEvolved: (lvl=@level) ->
    return lvl >= heroEvolveLevel

  evoLevel: (lvl=@level) ->
    if @isEvolved(lvl)
      return lvl - heroEvolveLevel
    return lvl

  _accumulateBonuses: (bonusType) ->
    return _.sum((
      if skill.isActive and skill.bonusType == bonusType
        skill.magnitude
      else 0
    ) for skill in @skills)

  getSelfDamageBoost: -> @_accumulateBonuses("ThisHeroDamage")

  getDps: (lvl=@level) ->
    if @isEvolved(lvl)
      num3 = levelIneffiency**@evoLevel(lvl) *
        (1 - (heroInefficiency * heroInefficiencySlowDown))**(@heroId + 30)
      num4 = @getUpgradeCost(lvl - 1) *
        (heroUpgradeBase**(lvl - (heroEvolveLevel - 1)) - 1) /
          (heroUpgradeBase - 1) * num3 * damageScaleDown
    else
      num3 = levelIneffiency**(lvl - 1) *
        (1 - (heroInefficiency * Math.min(@heroId, heroInefficiencySlowDown)))**@heroId
      num4 = @getUpgradeCost(lvl - 1) *
        (heroUpgradeBase**lvl - 1) / (heroUpgradeBase - 1) * num3 * damageScaleDown
    return Math.floor(num4 *
      (TapTitans.getTotalBonus("AllDamage") + @getSelfDamageBoost()) *
      TapTitans.getTotalBonus("ArtifactAllDamage"))

  getDpsDiff: (levelDelta=1) ->
    return @getDps(@level + levelDelta) - @getDps()


class Skill extends ReactiveObject
  constructor: (data, @owner, @prevSkill=null) ->
    @nextSkill = null
    {@name, @bonusType, @magnitude, @reqLevel, @cost, @skillId} = data
    @prevSkill?.nextSkill = @

    super
      _isActive: null

  id: -> "#{@owner.name}: #{@name}"

  isActive: ->
    if @owner.level < @reqLevel
      return false
    if @_isActive?
      return @_isActive
    return not @prevSkill? or @prevSkill.isActive()

  setActive: (active) ->
    console.log("#{@id()} - setActive(", active, ")")
    if active
      if @prevSkill? and not @prevSkill.isActive()
        @prevSkill?.setActive(true)
    else
      if @nextSkill?.isActive()
        @nextSkill?.setActive(false)
    @_isActive = active

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
    if @isActive()
      return @magnitude
    return 0


class Player extends Hero
  constructor: (data) ->
    super(data)
    @defineProperty('taps', 5)
    @level = 1

  getTapDamage: (lvl=@level) ->
    return (
      (
        (
          lvl * 1.05 ** lvl * (1 + TapTitans.getTotalBonus("AllDamage"))
        )
        + TapTitans.getTotalBonus("TapDamageFromDPS") * TapTitans.getTotalHeroDps()
      ) * (1 + TapTitans.getTotalBonus("TapDamagePassive")
      ) * (1 + TapTitans.getTotalBonus("ArtifactAllDamage")
      ) * (1 + TapTitans.getTotalBonus("TapDamageArtifact")
      )
    )

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
    super
      stage: 1


    @Player =  new Player(share.Data.Player)
    @Artifacts = (new Artifact(artifact) for artifact in share.Data.ArtifactInfo)
    @Heroes = (new Hero(hero) for hero in share.Data.HeroInfo)

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

    @_bonus =
      ArtifactAllDamage: (
        (do (artifact) -> -> artifact.getDamage()) for artifact in @Artifacts
      )
    for item in items
      if item.bonusType not of @_bonus
        @_bonus[item.bonusType] = []
      @_bonus[item.bonusType].push(do (item) -> -> item.getBonus())

  getTotalBonus: (type) ->
    return _.sum(bonus() for bonus in @_bonus[type])

  getTotalHeroDps: ->
    return _.sum(hero.getDps() for hero in @Heroes)

  nextArtifactCost: ->
    num = 1 + _.sum ((artifact.level > 0) for artifact in @Artifacts)
    return Math.floor(num * artifactCostFactor**num)

  getMonsterHealth: (stage=@stage) ->
    return 18.5 * 1.57**Math.min(stage, 150) * 1.17**Math.max(stage-150, 0)

  getBossHealth: (stage=@stage) ->
    return @getMonsterHealth(stage) * bossFactor[(stage-1)%5] *
      (1 + @getTotalBonus("BossLife"))

  getTotalHeroLevels: () ->
    return _.sum(hero.level for hero in @Heroes)

  getRelicsGained: (allHeroesAlive=true, stage=@stage) ->
    bonus = 1 + @getTotalBonus("PrestigeRelic")
    fromHeroes = (@getTotalHeroLevels() * bonus)//1000
    fromStages = Math.floor(
      (Math.max(0, stage - relicsFirstStage)//relicsStagesPerIncrease)**1.7 * bonus)
    relics = fromHeroes + fromStages
    if allHeroesAlive
      relics *= relicsAllHeroesBonus
    return relics




TapTitans = new Game()
