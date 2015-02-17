TT.heroEvolveLevel = 1001
TT.levelIneffiency = 0.904
TT.heroInefficiency = 0.019
TT.heroInefficiencySlowDown = 15
TT.heroUpgradeBase = 1.075
TT.evolveCostMultiplier = 10
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

TT.GetEfficiency = () ->
  output = []
  text = ""
  bestHero = TT.HeroInfo[0]
  bestSkill = TT.HeroInfo[0].skills[0]
  for x in [0...10000]
    for hero in TT.HeroInfo
      if hero.isActive
        if hero.efficiency < bestHero.efficiency
          bestHero = hero
        for skill in hero.skills
          if not skill.isActive and skill.efficiency < bestSkill.efficiency
            bestSkill = skill
    if TT.Player.efficiency < bestHero.efficiency
      bestHero = TT.Player
    if bestSkill.efficiency < bestHero.efficiency
      bestSkillOwner = TT.HeroInfo[bestSkill.owner]
      if bestSkillOwner.heroLevel == bestSkill.reqLevel
        bestSkill.isActive = true
        if output[output.length-1]?.name == bestSkillOwner.name
          output[output.length-1].level = bestSkillOwner.heroLevel
        else
          output.push({name: bestSkillOwner.name, level: bestSkillOwner.heroLevel})

        output.push({name: bestSkill.name + " - " + bestSkill.reqLevel, level: bestSkillOwner.name})
        bestSkill.efficiency = 1000000
      else
        bestSkillOwner.heroLevel += 1
        if output[output.length-1]?.name == bestSkillOwner.name
          output[output.length-1].level = bestSkillOwner.heroLevel
        else
          output.push({name: bestSkillOwner.name, level: bestSkillOwner.heroLevel})
    else
      bestHero.heroLevel += 1
      if output[output.length-1]?.name == bestHero.name
        output[output.length-1].level = bestHero.heroLevel
      else
        output.push({name: bestHero.name, level: bestHero.heroLevel})

    TT.GetStatBonusAllDamage()
    TT.GetStatBonusAllGold()
    TT.GetStatBonusCritDamagePassive()
    TT.GetStatBonusTapDamageFromDPS()
    TT.GetStatBonusCritChance()
    TT.GetStatBonusTapDamagePassive()
    TT.SetSkillsForEfficiency()
    TT.UpdateAllHeroesStats()

    if output.length > parseInt($("#numberofpredictions").val())
      $("#output").html("")
      text = ""
      for out in output
        text += out.name + " - " + out.level + "<br>"
      $("#output").html(text)
      break

TT.SetSkillsForEfficiency = () ->
  for hero in TT.HeroInfo
    for skill in hero.skills
      if skill.reqLevel < hero.heroLevel
        skill.isActive = true

TT.GetLevels = () ->
  for hero in TT.HeroInfo
    hero.heroLevel = parseInt($("#hero#{hero.heroID}heroLevel").val()) or 0

  TT.Player.heroLevel = parseInt($("#player0heroLevel").val()) or 1
  TT.Player.clicks = parseInt($("#player0clicks").val()) or 5
  for artifact in TT.ArtifactInfo
    artifact.level = parseInt($("##{artifact.artifactID}level").val()) or 0
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
  for artifact in TT.ArtifactInfo
    artifact.currentBonus = artifact.bonusPerLevel * artifact.level
    artifact.nextLevelBonusDiff = artifact.bonusPerLevel * artifact.level
    artifact.upgradeCost = TT.getArtifactUpgradeCost(artifact)
  TT.artifactBonusDamage = 0
  for artifact in TT.ArtifactInfo
    artifact.currentDamageBonus = TT.totalDamageArtifactBonus(artifact.damageBonus, artifact.level)
    artifact.nextLevelDamageBonusDiff = TT.totalDamageArtifactBonus(artifact.damageBonus, artifact.level + 1) - artifact.currentDamageBonus
    TT.artifactBonusDamage += artifact.currentDamageBonus

TT.totalDamageArtifactBonus = (damageBonus, level) ->
  if level > 0
    return damageBonus * (1 + 0.5 * (level - 1)) * (1 + TT.Artifact.TinctureOfTheMaker.currentBonus)
  return 0



TT.accumulateStatBonus = (bonusType) ->
  return _.reduce TT.HeroInfo,
    (n, hero) -> n + TT.accumulateHeroStatBonus(hero, bonusType)
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
  TT.CritDamagePassive = (10 + 10 * TT.accumulateStatBonus("CritDamagePassive")) * (1 + TT.Artifact.HerosThrust.currentBonus)

TT.GetStatBonusTapDamagePassive = () ->
  TT.TapDamagePassive = TT.accumulateStatBonus("TapDamagePassive")

TT.UpdateAllHeroesStats = () ->
  TT.currentAllHeroDPS = 0
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
    for skill in hero.skills
      TT.updateSkill(skill)

TT.updateSkill = (skill) ->
  if not skill.isActive
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
    skill.nextUpgradeCost = TT.GetSkillCost(skill)
    skill.efficiency = skill.nextUpgradeCost/(skill.nextLevelSalaryDiff - skill.currentSalary)
    if TT.HeroInfo[skill.owner].heroLevel == skill.reqLevel
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

TT.getArtifactRelicsSpent = (artifact) ->
  num = 0
  for x in [1...artifact.level]
    num += Math.round(artifact.costCoEff * (x + 1)**artifact.costExpo)
  return num

TT.GetDPSByLevel = (hero, level) ->
  num3 = 0
  if TT.IsEvolved(level)
    num3 = TT.levelIneffiency**(level - TT.heroEvolveLevel) * (1 - (TT.heroInefficiency * TT.heroInefficiencySlowDown))**(hero.heroID + 30)
  else
    num3 = TT.levelIneffiency**(level - 1) * (1 - (TT.heroInefficiency * Math.min(hero.heroID, TT.heroInefficiencySlowDown)))**hero.heroID
  num4 = 0
  if TT.IsEvolved(level)
    num4 = TT.GetUpgradeCostByLevel(level - 1, hero.cost) * (TT.heroUpgradeBase**(level - (TT.heroEvolveLevel - 1)) - 1) / (TT.heroUpgradeBase - 1) * num3 * TT.dMGScaleDown
  else
    num4 = TT.GetUpgradeCostByLevel(level - 1, hero.cost) * (TT.heroUpgradeBase**level - 1) / (TT.heroUpgradeBase - 1) * num3 * TT.dMGScaleDown
  return num4 * (1 + TT.currentPassiveThisHeroDamage(hero) + TT.StatBonusAllDamage) * (1 + TT.artifactBonusDamage)

TT.UpdatePlayerStats = () ->
  TT.Player.currentDamage = TT.GetAttackDamageByLevel(TT.Player.heroLevel)
  TT.Player.nextLevelDMGDiff = TT.GetAttackDamageByLevel(TT.Player.heroLevel + 1) - TT.Player.currentDamage
  TT.Player.nextUpgradeCost = TT.GetPlayerUpgradeCostByLevel(TT.Player.heroLevel)
  TT.Player.MinCritDamage = TT.Player.currentDamage * TT.CritDamagePassive * 0.3
  TT.Player.MaxCritDamage = TT.Player.currentDamage * TT.CritDamagePassive
  TT.Player.AvgCritDamage = TT.Player.currentDamage * TT.CritDamagePassive * 0.65
  TT.Player.CritDamage = TT.CritChance*TT.Player.AvgCritDamage + (1 - TT.CritChance)*TT.Player.currentDamage
  TT.Player.trueDamage = TT.getPlayerTrueDamage(TT.Player.clicks, TT.Player.heroLevel)
  TT.Player.nextLeveltrueDamageDiff = TT.getPlayerTrueDamage(TT.Player.clicks, TT.Player.heroLevel + 1) - TT.Player.trueDamage

TT.getPlayerTrueDamage = (clicks, iLevel) ->
  num1 = TT.GetAttackDamageByLevel(iLevel)
  num2 = num1 * TT.CritDamagePassive * 0.65
  num3 = TT.CritChance*num2 + (1-TT.CritChance)*num1
  return num3 * clicks

TT.GetAttackDamageByLevel = (iLevel) ->
  num = iLevel * 1.05**iLevel
  num3 = TT.TapDamagePassive
  num4 = TT.TapDamageFromDPS * TT.currentAllHeroDPS
  num5 = 0
  num7 = TT.Artifact.DrunkenHammer.currentBonus
  num8 = (num * (1 + TT.StatBonusAllDamage) + num4) * (1 + num3) * (1 + num5) * (1 + TT.artifactBonusDamage) * (1 + num7)
  if num8 <= 1
    num8 = 1
  return num8

TT.GetPlayerUpgradeCostByLevel = (iLevel) ->
    num = Math.min(25, 3 + iLevel) * 1.074**iLevel
    return Math.ceil( num * (1 + TT.Artifact.RingOfWonderousCharm.currentBonus))

TT.GetSkillCost = (skill) ->
  hero = TT.HeroInfo[skill.owner]
  num = TT.GetUpgradeCostByMultiLevel(hero.heroLevel, skill.reqLevel, hero.cost)
  num2 = 0
  for skill2 in hero.skills
    if not skill2.isActive
      num2 += TT.GetUpgradeCostByLevel(skill2.reqLevel, hero.cost) * 5
    if skill2.name == skill.name
      break
  return num + num2

TT.Save = () ->
  TT.UpdateTables()
  heroes = []
  for hero in TT.HeroInfo
    heroes.push({level: hero.heroLevel, skills: [skill.isActive for skill in hero.skills]})
  player =
    level: TT.Player.heroLevel
    clicks: TT.Player.clicks
  artifacts = [artifact.level for artifact in TT.ArtifactInfo]
  $("#savedata").val(JSON.stringify([heroes, player, artifacts]))

TT.Load = () ->
  txt = $("#savedata").val()
  [savedHeroes, savedPlayer, savedArtifacts] = jQuery.parseJSON(txt)
  for [hero, savedHero] in _.zip(TT.HeroInfo, savedHeroes)
    hero.heroLevel = savedHero.level
    for [skill, savedSkillActive] in _.zip(hero.skills, savedHero.skills)
      skill.isActive = savedSkillActive
      $("#skill#{skill.skillID}").prop("checked", skill.isActive)
      $("#hero#{hero.heroID}heroLevel").val(hero.heroLevel)
  TT.Player.clicks = savedPlayer.clicks
  TT.Player.heroLevel = savedPlayer.level
  $("#player0clicks").val(TT.Player.clicks)
  $("#player0heroLevel").val(TT.Player.heroLevel)
  for [artifact, savedArtifactLevel] in _.zip(TT.ArtifactInfo, savedArtifacts)
    artifact.level = savedArtifactLevel
    $("##{artifact.artifactID}level").val(artifact.level)
  TT.UpdateTables()

TT.EfficiencyCalculations = () ->
  $("#output").html("")
  TT.UpdateTables()
  TT.GetEfficiency()

#$(TT.UpdateTables)
