TT.GetLevels = () ->
  for hero in TT.HeroInfo
    hero.heroLevel = parseInt($("#hero#{hero.heroID}heroLevel").val())

  TT.Player.heroLevel = parseInt($("#player0heroLevel").val())
  TT.Player.clicks = parseInt($("#player0clicks").val())
  for artifact in TT.ArtifactInfo
    artifact.level = parseInt($("##{artifact.artifactID}level").val())
    if artifact.level > artifact.maxLevel and artifact.maxLevel > 0
      artifact.level = artifact.maxLevel
      $("##{artifact.artifactID}level").val(artifact.maxLevel)

TT.SetSkillsForTable = () ->
  for hero in TT.HeroInfo
    for skill in hero.skills
      $skillNode = $("#skill#{skill.skillID}")
      if skill.reqLevel < hero.heroLevel
        skill.isActive = true
      else if skill.reqLevel > hero.heroLevel
        skill.isActive = false
      else
        skill.isActive = $skillNode.is(":checked")
      $skillNode.prop("checked", skill.isActive)

TT.UpdateArtifactsStats = () ->
  TT.artifactBonusDamage = 0.0
  for artifact in TT.ArtifactInfo
    artifact.currentBonus = artifact.bonusPerLevel * artifact.level
    artifact.nextLevelBonusDiff = artifact.bonusPerLevel * artifact.level
    artifact.upgradeCost = TT.getArtifactUpgradeCost(artifact)

    artifact.currentDamageBonus = TT.totalDamageArtifactBonus(artifact.damageBonus, artifact.level)
    artifact.nextLevelDamageBonusDiff = TT.totalDamageArtifactBonus(artifact.damageBonus, artifact.level + 1) - artifact.currentDamageBonus
    TT.artifactBonusDamage += artifact.currentDamageBonus

TT.getArtifactUpgradeCost = (artifact) ->
  if artifact.level == 0
    return TT.NextArtifactCost()
  return Math.round(artifact.costCoEff * (artifact.level + 1)**artifact.costExpo)

TT.NextArtifactCost = () ->
  num = _.reduce TT.ArtifactInfo,
    (n, artifact) -> n + (artifact.level > 0)
    1

  return Math.floor(num * 1.35**num)

TT.totalDamageArtifactBonus = (damageBonus, level) ->
  if level > 0
    return damageBonus * (1 + 0.5 * (level - 1)) * (1 + TT.Artifact.TinctureOfTheMaker.currentBonus)
  return 0



TT.accumulateStatBonus = (bonusType) ->
  return _.reduce TT.HeroInfo,
    (n, hero) -> TT.accumulateHeroStatBonus(hero, bonusType)
    0

TT.accumulateHeroStatBonus = (hero, bonusType) ->
  return _.reduce hero.skills,
    (n, skill) -> n + if skill.isActive and skill.bonusType == bonusType then skill.magnitude else 0
    0

TT.currentPassiveThisHeroDamage = (hero) -> TT.accumulateHeroStatBonus(hero, "ThisHeroDamage")

TT.GetStatBonusAllDamage = () -> TT.StatBonusAllDamage = TT.accumulateStatBonus("AllDamage")

TT.GetStatBonusAllGold = () ->
  TT.StatBonusGoldAll = TT.Artifact.FuturesFortune.currentBonus + TT.accumulateStatBonus("GoldAll")

TT.GetStatBonusTapDamageFromDPS = () ->
  TT.TapDamageFromDPS = TT.accumulateStatBonus("TapDamageFromDPS")

TT.GetStatBonusCritChance = () ->
  TT.CritChance = 0.02 + TT.Artifact.DeathSeeker.currentBonus + TT.accumulateStatBonus("CritChance")

TT.GetStatBonusCritDamagePassive = () ->
  TT.CritDamagePassive = (10.0 + 10 * TT.accumulateStatBonus("CritDamagePassive")) * (1 + TT.Artifact.HerosThrust.currentBonus)

TT.GetStatBonusTapDamagePassive = () ->
  TT.TapDamagePassive = TT.accumulateStatBonus("TapDamagePassive")

TT.UpdateAllHeroesStats = () ->
  TT.currentAllHeroDPS = 0.0
  for hero in TT.HeroInfo
    hero.currentPassiveThisHeroDamage = TT.currentPassiveThisHeroDamage(hero)
    hero.currentDPS = TT.GetDPSByLevel(hero, hero.heroLevel)
    hero.nextLevelDPSDiff = TT.GetDPSByLevel(hero, hero.heroLevel + 1) - hero.currentDPS
    hero.nextUpgradeCost = TT.GetUpgradeCostByLevel(hero.heroLevel, hero.cost)
    if hero.heroID <= 1
      hero.isActive = true
    else
      hero.isActive = TT.HeroInfo[hero.heroID-2].heroLevel > 0
    TT.currentAllHeroDPS += hero.currentDPS
  TT.UpdatePlayerStats()
  TT.currentAllHeroDPS += TT.getPlayerTrueDamage(TT.Player.clicks, TT.Player.heroLevel)
  if TT.currentAllHeroDPS == 0
    TT.currentAllHeroDPS = 1e-100
  TT.Player.currentSalary = TT.currentAllHeroDPS  * (1 + TT.StatBonusGoldAll)
  TT.Player.nextLevelSalaryDiff = (TT.currentAllHeroDPS + TT.Player.nextLeveltrueDamageDiff) * (1 + TT.StatBonusGoldAll)
  TT.Player.efficiency = TT.Player.nextUpgradeCost/(TT.Player.nextLevelSalaryDiff - TT.Player.currentSalary)

  for hero in TT.HeroInfo
    hero.currentSalary = TT.currentAllHeroDPS  * (1 + TT.StatBonusGoldAll)
    hero.nextLevelSalaryDiff = (TT.currentAllHeroDPS + hero.nextLevelDPSDiff) * (1 + TT.StatBonusGoldAll)
    hero.efficiency = hero.nextUpgradeCost/(hero.nextLevelSalaryDiff - hero.currentSalary)
    #for (var x = 0; x < hero.skills.length; x++)
    for skill in hero.skills
      TT.updateSkill("AllDamage", skill, hero)
      TT.updateSkill("GoldAll", skill, hero)
      TT.updateSkill("ThisHeroDamage", skill, hero)
      TT.updateSkill("CritDamagePassive", skill, hero)
      TT.updateSkill("TapDamageFromDPS", skill, hero)
      TT.updateSkill("CritChance", skill, hero)
      TT.updateSkill("TapDamagePassive", skill, hero)
      TT.updateSkill("GoldTreasurePassive", skill, hero)

TT.updateSkill = (bonusType, skill, hero) ->
  if not skill.isActive and skill.bonusType == bonusType
    skill.isActive = true
    TT.GetStatBonusAllDamage()
    TT.GetStatBonusAllGold()
    TT.GetStatBonusCritDamagePassive()
    TT.GetStatBonusTapDamageFromDPS()
    TT.GetStatBonusCritChance()
    TT.GetStatBonusTapDamagePassive()
    skill.dps = TT.getPlayerTrueDamage(TT.Player.clicks, TT.Player.heroLevel)
    for hero2 in TT.HeroInfo
      if hero2.name != TT.HeroInfo[skill.owner].name
        skill.dps += TT.GetDPSByLevel(hero2, hero2.heroLevel)
      else
        if skill.reqLevel >= hero2.heroLevel
          skill.dps += TT.GetDPSByLevel(hero2, skill.reqLevel)
        else
          skill.dps += TT.GetDPSByLevel(hero2, hero2.heroLevel)
    skill.isActive = false
    TT.GetStatBonusAllDamage()
    TT.GetStatBonusAllGold()
    TT.GetStatBonusCritDamagePassive()
    TT.GetStatBonusTapDamageFromDPS()
    TT.GetStatBonusCritChance()
    TT.GetStatBonusTapDamagePassive()
    skill.currentSalary = TT.currentAllHeroDPS  * (1 + TT.StatBonusGoldAll)
    skill.nextLevelSalaryDiff = skill.dps * (1 + TT.StatBonusGoldAll)
    skill.nextUpgradeCost = TT.GetSkillCost(skill, hero)
    skill.efficiency = skill.nextUpgradeCost/(skill.nextLevelSalaryDiff - skill.currentSalary)
    if hero.heroLevel == skill.reqLevel
      skill.efficiency = 0

TT.printAll = () ->
  for hero in TT.HeroInfo
    TT.printHeroInfo(hero)
  for artifact in TT.ArtifactInfo
    TT.printArtifactInfo(artifact)
  $("#player0nextUpgradeCost").html(TT.numberFormat(TT.Player.nextUpgradeCost))
  if TT.Player.currentDamage > 1000000
    $("#player0currentDPS").html(TT.Player.currentDamage.toExponential(3))
  else
    $("#player0currentDPS").html(Math.floor(TT.Player.currentDamage))
  if TT.Player.nextLevelDMGDiff > 1000000
    $("#player0nextLevelDPSDiff").html("+ "+TT.Player.nextLevelDMGDiff.toExponential(3))
  else
    $("#player0nextLevelDPSDiff").html("+ "+Math.floor(TT.Player.nextLevelDMGDiff))
  $("#playerdata").html(
            "Total Damage: " + TT.numberFormat(TT.Player.trueDamage) + "<br>" +
            "Next Level Total Damage: " + TT.numberFormat(TT.Player.nextLeveltrueDamageDiff) + "<br>" +
            "Min crit dmg: " + TT.numberFormat(TT.Player.MinCritDamage) + "<br>" +
            "Max crit dmg: " + TT.numberFormat(TT.Player.MaxCritDamage) + "<br>" +
            "Avg crit dmg: " + TT.numberFormat(TT.Player.AvgCritDamage) + "<br>" +
            "Crit dmg: " + TT.numberFormat(TT.Player.CritDamage) + "<br>" +
            "<br>" +
            "All Damage Bonus: " + TT.StatBonusAllDamage + "<br>" +
            "All Gold Bonus: " + TT.StatBonusGoldAll + "<br>" +
            "Crit Damage Bonus: " + TT.CritDamagePassive + "<br>" +
            "Tap Dmg from DPS Bonus: " + TT.TapDamageFromDPS + "<br>" +
            "Crit Chance Bonus: " + TT.CritChance + "<br>" +
            "Tap Damage Bonus: " + TT.TapDamagePassive + "<br>" +
            "<br>" +
            "Total DPS: " + TT.numberFormat(TT.currentAllHeroDPS) + "<br>"
            )

TT.UpdateTables = () ->
  TT.GetLevels()
  TT.SetSkillsForTable()
  TT.UpdateArtifactsStats()
  TT.GetStatBonusAllDamage()
  TT.GetStatBonusAllGold()
  TT.GetStatBonusCritDamagePassive()
  TT.GetStatBonusTapDamageFromDPS()
  TT.GetStatBonusCritChance()
  TT.GetStatBonusTapDamagePassive()
  TT.UpdateAllHeroesStats()
  TT.printAll()

TT.printHeroInfo = (hero) ->
  $("#hero#{hero.heroID}currentDPS").html(TT.numberFormat(hero.currentDPS))
  $("#hero#{hero.heroID}nextLevelDPSDiff").html("+ " + TT.numberFormat(hero.nextLevelDPSDiff))
  $("#hero#{hero.heroID}nextUpgradeCost").html(TT.numberFormat(hero.nextUpgradeCost))
  for skill in hero.skills
    $("#skill#{skill.skillID}").prop("title",
                              skill.name + "\n" +
                              skill.bonusType + "\n" +
                              skill.magnitude + "\n" +
                              skill.nextUpgradeCost
                              )

TT.printArtifactInfo = (artifact) ->
  if artifact.level >= artifact.maxLevel and artifact.maxLevel > 0
    $("##{artifact.artifactID}upgradeCost").html("MAX LEVEL")
    $("##{artifact.artifactID}upgradeCost").prop("title", TT.getArtifactRelicsSpent(artifact))
    $("##{artifact.artifactID}DamageBonus").html(Math.round(artifact.currentDamageBonus*10000)/100+"%")
    $("##{artifact.artifactID}artifactBonus").html(Math.round(artifact.currentBonus*10000)/100+"%")
  else
    $("##{artifact.artifactID}upgradeCost").html(artifact.upgradeCost)
    $("##{artifact.artifactID}upgradeCost").prop("title", TT.getArtifactRelicsSpent(artifact))
    $("##{artifact.artifactID}DamageBonus").html(Math.round(artifact.currentDamageBonus*10000)/100+"%" + " (+" + Math.round(artifact.nextLevelDamageBonusDiff*10000)/100 + "%)")
    if artifact.bonusPerLevel > 0
      $("##{artifact.artifactID}artifactBonus").html(Math.round(artifact.currentBonus*10000)/100+"%" + " (+" + Math.round(artifact.bonusPerLevel*10000)/100 + "%)")
    else
      $("##{artifact.artifactID}artifactBonus").html(Math.round(artifact.currentBonus*10000)/100+"%" + " (" + Math.round(artifact.bonusPerLevel*10000)/100 + "%)")

