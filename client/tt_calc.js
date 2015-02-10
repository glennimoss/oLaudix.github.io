//$(function () {
  /*
  for (var i = 0; i < HeroInfo.length; i++) {
    var hero = HeroInfo[i]
      , key = "hero" + i
      , tr = hero.targetBox = $("<tr></tr>")
      ;
    tr.append($("<td></td>").text(hero.name).attr("id", key+"name"));
    hero.used1 = $("<input></input>").attr("type", "checkbox").attr("id", key+"skill1").attr("title", "ha");
    hero.used2 = $("<input></input>").attr("type", "checkbox").attr("id", key+"skill2").attr("title", "ha");
    hero.used3 = $("<input></input>").attr("type", "checkbox").attr("id", key+"skill3").attr("title", "ha");
    hero.used4 = $("<input></input>").attr("type", "checkbox").attr("id", key+"skill4").attr("title", "ha");
    hero.used5 = $("<input></input>").attr("type", "checkbox").attr("id", key+"skill5").attr("title", "ha");
    hero.used6 = $("<input></input>").attr("type", "checkbox").attr("id", key+"skill6").attr("title", "ha");
    hero.used7 = $("<input></input>").attr("type", "checkbox").attr("id", key+"skill7").attr("title", "ha");
    tr.append($("<td></td>").append(hero.used1).append(hero.used2).append(hero.used3).append(hero.used4).append(hero.used5).append(hero.used6).append(hero.used7));
    if (hero.nextUpgradeCost > 1000000) {
      tr.append($("<td></td>").append(hero.nextUpgradeCost.toExponential(2)).attr("id", key+"nextUpgradeCost"));
    } else {
      tr.append($("<td></td>").append(hero.nextUpgradeCost).attr("id", key+"nextUpgradeCost"));
    }
    tr.append($("<td></td>").append(hero.currentDPS).attr("id", key+"currentDPS"));
    tr.append($("<td></td>").append(hero.nextLevelDPSDiff).attr("id", key+"nextLevelDPSDiff"));
    tr.append(
      $("<td></td>").append($("<input></input>")
                    .attr("type", "text").val(0)
                    .attr("id", key+"heroLevel")
                    .attr("tabindex", i+1)
                    .attr("size", 4)
                    )
    );
    tr.append("\n\n");
    $("#ancienttbl").append(tr);
  }

  {
    var tr2 = Player.targetBox = $("<tr></tr>");
    tr2.append($("<td></td>").append(Player.name).attr("id", "player0name"));
    tr2.append($("<td></td>").append(Player.nextUpgradeCost).attr("id", "player0nextUpgradeCost"));
    tr2.append($("<td></td>").append(Player.currentDPS).attr("id", "player0currentDPS"));
    tr2.append($("<td></td>").append(Player.nextLevelDPSDiff).attr("id", "player0nextLevelDPSDiff"));
    tr2.append($("<td></td>").append($("<input></input>").attr("type", "text").val(1).attr("id", "player0heroLevel")));
    tr2.append($("<td></td>").append($("<input></input>").attr("type", "text").val(5).attr("id", "player0clicks")));
    tr2.append("\n\n");
    $("#playertbl").append(tr2);
  }
  */

  function printHeroInfo(hero) {
    //if (hero.currentDPS > 1000000) { $("#Hero"+(hero.heroID)+"currentDPS").html(hero.currentDPS.toExponential(3)); } else { $("#Hero"+hero.heroID+"currentDPS").html(Math.floor(hero.currentDPS)); }
    //if (hero.nextLevelDPSDiff > 1000000) { $("#Hero"+(hero.heroID)+"nextLevelDPSDiff").html("+ "+hero.nextLevelDPSDiff.toExponential(3)); } else { $("#Hero"+hero.heroID+"nextLevelDPSDiff").html("+ "+Math.floor(hero.nextLevelDPSDiff)); }
    //if (hero.nextUpgradeCost > 1000000) { $("#Hero"+(hero.heroID)+"nextUpgradeCost").html(hero.nextUpgradeCost.toExponential(3)); } else { $("#Hero"+hero.heroID+"nextUpgradeCost").html(Math.floor(hero.nextUpgradeCost)); }
    if (hero.currentDPS > 1000) { $("#Hero"+(hero.heroID)+"currentDPS").html(numberFormat(hero.currentDPS)); } else { $("#Hero"+hero.heroID+"currentDPS").html(Math.floor(hero.currentDPS)); }
    if (hero.nextLevelDPSDiff > 1000) { $("#Hero"+(hero.heroID)+"nextLevelDPSDiff").html("+ "+numberFormat(hero.nextLevelDPSDiff)); } else { $("#Hero"+hero.heroID+"nextLevelDPSDiff").html("+ "+Math.floor(hero.nextLevelDPSDiff)); }
    $("#Hero"+(hero.heroID)+"nextUpgradeCost").html(numberFormat(hero.nextUpgradeCost));
    //$("#Hero"+hero.heroID+"name").prop("title", hero.efficiency)
    for (var x = 0; x < 7; x++)
    {
      //$("#Hero"+hero.heroID+"skill"+(x+1)).prop("checked", hero.skills[x].isActive);
      $("#Hero"+(hero.heroID)+"skill"+(x+1)).prop("title",
                                hero.skills[x].name + "\n" +
                                hero.skills[x].bonusType + "\n" +
                                hero.skills[x].magnitude + "\n" +
                                hero.skills[x].nextUpgradeCost
                                // + hero.skills[x].efficiency
                                );
    }
    //$("#Hero"+(hero.heroID)+"currentDPS").prop("title", "Additional dmg: " + (StatBonusAllDamage + hero.currentPassiveThisHeroDamage)*100 + "%");
  }

  function printArtifactInfo(artifact) {
    if (artifact.level >= parseInt(artifact.maxLevel) && parseInt(artifact.maxLevel) > 0) {
      $("#"+(artifact.artifactID)+"upgradeCost").html("MAX LEVEL");
      $("#"+(artifact.artifactID)+"upgradeCost").prop("title", getArtifactRelicsSpent(artifact));
      $("#"+(artifact.artifactID)+"DamageBonus").html(Math.round(artifact.currentDamageBonus*10000)/100+"%");
      $("#"+(artifact.artifactID)+"artifactBonus").html(Math.round(artifact.currentBonus*10000)/100+"%");
    } else {
      $("#"+(artifact.artifactID)+"upgradeCost").html(artifact.upgradeCost);
      $("#"+(artifact.artifactID)+"upgradeCost").prop("title", getArtifactRelicsSpent(artifact));
      $("#"+(artifact.artifactID)+"DamageBonus").html(Math.round(artifact.currentDamageBonus*10000)/100+"%" + " (+" + Math.round(artifact.nextLevelDamageBonusDiff*10000)/100 + "%)");
      if (artifact.bonusPerLevel > 0) {
        $("#"+(artifact.artifactID)+"artifactBonus").html(Math.round(artifact.currentBonus*10000)/100+"%" + " (+" + Math.round(artifact.bonusPerLevel*10000)/100 + "%)");
      } else {
        $("#"+(artifact.artifactID)+"artifactBonus").html(Math.round(artifact.currentBonus*10000)/100+"%" + " (" + Math.round(artifact.bonusPerLevel*10000)/100 + "%)");
      }
    }
  }

  function UpdateArtifactsStats() {
    for (var i = 0; i < ArtifactInfo.length; i++) {
      ArtifactInfo[i].currentBonus = totalArtifactBonus(ArtifactInfo[i].bonusPerLevel, ArtifactInfo[i].level);
      ArtifactInfo[i].nextLevelBonusDiff = totalArtifactBonus(ArtifactInfo[i].bonusPerLevel, ArtifactInfo[i].level);
      ArtifactInfo[i].upgradeCost = getArtifactUpgradeCost(ArtifactInfo[i]);
    }
    artifactBonusDamage = 0.0;
    for (var x = 0; x < ArtifactInfo.length; x++) {
      ArtifactInfo[x].currentDamageBonus = totalDamageArtifactBonus(ArtifactInfo[x], ArtifactInfo[x].level);
      //alert(ArtifactInfo[x].currentDamageBonus + " - " + ArtifactInfo[x].artifactID + " - " + ArtifactInfo[x].level);
      ArtifactInfo[x].nextLevelDamageBonusDiff = totalDamageArtifactBonus(ArtifactInfo[x], ArtifactInfo[x].level + 1) - ArtifactInfo[x].currentDamageBonus;
      artifactBonusDamage += ArtifactInfo[x].currentDamageBonus;
    }
    //$("#artifactbonus").val(artifactBonusDamage*100);
  }

  function totalArtifactBonus(bonusPerLevel, level) {
    return bonusPerLevel * level;
  }

  function getArtifactUpgradeCost(artifact) {
    if (artifact.level == 0) { return NextArtifactCost(); }
    var num1 = artifact.CostCoEff * Math.pow(artifact.level + 1, artifact.CostExpo);
    var num2 = Math.round(num1);
    return num2;
  }

  function getArtifactRelicsSpent(artifact) {
    var num = 0.0;
    for (var x = 1; x < artifact.level; x++)
    {
      var num1 = artifact.CostCoEff * Math.pow(x + 1, artifact.CostExpo);
      var num2 = Math.round(num1);
      num += num2;
    }
    return num;
  }

  function NextArtifactCost() {
    var num = 1;
    for (var i = 0; i < ArtifactInfo.length; i++)
    {
      if (ArtifactInfo[i].level > 0) { num += 1; }
    }
    return Math.floor((num * Math.pow(1.35, num)));
  }

  function totalDamageArtifactBonus(artifact, level) {
    if (level > 0)
    {
      return (artifact.DamageBonus * (1.0 + (0.5 * (level - 1)))) * (1 + ArtifactInfo[25].currentBonus);
    }
    return 0;
  }

  function GetDPSByLevel(hero, level) {
      var num3 = 0.0;
      if (IsEvolved(level))
      {
        num3 = Math.pow(levelIneffiency, (level - heroEvolveLevel)) * Math.pow((1.0 - (heroInefficiency * heroInefficiencySlowDown)), (hero.heroID + 30));
      }
      else
      {
        num3 = Math.pow(levelIneffiency, (level - 1)) * Math.pow((1.0 - (heroInefficiency * Math.min(hero.heroID, heroInefficiencySlowDown))), hero.heroID);
      }
      var num4 = 0.0;
      if (IsEvolved(level))
      {
        num4 = (((GetUpgradeCostByLevel(level - 1, hero.cost) * (Math.pow(heroUpgradeBase, (level - (heroEvolveLevel - 1))) - 1.0)) / ((heroUpgradeBase - 1.0))) * num3) * dMGScaleDown;
      }
      else
      {
        num4 = (((GetUpgradeCostByLevel(level - 1, hero.cost) * (Math.pow(heroUpgradeBase, level) - 1.0)) / ((heroUpgradeBase - 1.0))) * num3) * dMGScaleDown;
      }
      return (num4 * (1.0 + currentPassiveThisHeroDamage(hero) + StatBonusAllDamage)) * (1.0 + artifactBonusDamage);
  }

  function IsEvolved(iLevel) {
    return (iLevel >= heroEvolveLevel);
  }

  function GetUpgradeCostByLevel(iLevel, purchaseCost) {
      var num = 0.0;
      num = GetHeroBaseCost(purchaseCost, iLevel) * Math.pow(heroUpgradeBase, iLevel);
      var a = num * (1.0 + ArtifactInfo[23].currentBonus);
      return Math.ceil(a);
  }

  function UpdatePlayerStats() {
    Player.currentDamage = GetAttackDamageByLevel(Player.heroLevel);
    Player.nextLevelDMGDiff = GetAttackDamageByLevel(Player.heroLevel + 1) - Player.currentDamage;
    Player.nextUpgradeCost = GetPlayerUpgradeCostByLevel(Player.heroLevel);
    Player.MinCritDamage = Player.currentDamage * CritDamagePassive * 0.3;
    Player.MaxCritDamage = Player.currentDamage * CritDamagePassive;
    Player.AvgCritDamage = Player.currentDamage * CritDamagePassive * 0.65;
    Player.CritDamage = ((CritChance*100*Player.AvgCritDamage) + ((1-CritChance)*100*Player.currentDamage))/100;
    Player.trueDamage = getPlayerTrueDamage(Player.clicks, Player.heroLevel);
    Player.nextLeveltrueDamageDiff = getPlayerTrueDamage(Player.clicks, Player.heroLevel + 1) - Player.trueDamage;
  }

  function getPlayerTrueDamage(clicks, iLevel) {
    var num1 = GetAttackDamageByLevel(iLevel);
    var num2 = num1 * CritDamagePassive * 0.65;
    var num3 = ((CritChance*100*num2) + ((1-CritChance)*100*num1))/100;
    var num4 = num3 * clicks;
    return num4;
  }

  function GetAttackDamageByLevel(iLevel) {
      var num = iLevel * Math.pow(1.05, iLevel);
      var num3 = TapDamagePassive;
      var num4 = TapDamageFromDPS * currentAllHeroDPS;
      //var num5 = PlayerModel.instance.GetStatBonus(BonusType.TapDamageActive);
    var num5 = 0;
      var num7 = ArtifactInfo[28].currentBonus;
      //var num8 = (((((num * (1.0 + statBonus)) + num4) * (1.0 + num3)) * (1.0 + num5)) * (1.0 + artifactDamageBonus)) * (1.0 + num7);
    var num8 = (((((num * (1.0 + StatBonusAllDamage)) + num4) * (1.0 + num3)) * (1.0 + num5)) * (1.0 + artifactBonusDamage)) * (1.0 + num7);
    //alert(num8);
      if (num8 <= 1.0)
      {
          num8 = 1.0;
      }
      return num8;
  }

  function GetPlayerUpgradeCostByLevel(iLevel) {
      var num = Math.min(25, 3 + iLevel) * Math.pow(1.074, iLevel);
      var a = num * (1.0 + ArtifactInfo[23].currentBonus);
      return Math.ceil(a);
  }

  function UpdateAllHeroesStats() {
    currentAllHeroDPS = 0.0;
    for (var i = 0; i < 30; i++)
    {
      var hero = HeroInfo[i];
      hero.currentPassiveThisHeroDamage = currentPassiveThisHeroDamage(hero);
      hero.currentDPS = GetDPSByLevel(hero, hero.heroLevel);
      hero.nextLevelDPSDiff = GetDPSByLevel(hero, hero.heroLevel + 1) - hero.currentDPS;
      hero.nextUpgradeCost = GetUpgradeCostByLevel(hero.heroLevel, hero.cost);
      if (hero.heroID >= 2)
      {
        hero.isActive = false;
        if (HeroInfo[hero.heroID-2].heroLevel > 0){ hero.isActive = true; }
      }
      else if (hero.heroID <= 1)
      {
        hero.isActive = true;
      }
      currentAllHeroDPS += HeroInfo[i].currentDPS;
      //hero.nextSkill = hero.skills[0];
      //$("#Hero1skill1").prop("checked", HeroInfo[0].skills[0].isActive);
    }
    //if (currentAllHeroDPS == 0) { currentAllHeroDPS = 1e-100; }
    UpdatePlayerStats();
    currentAllHeroDPS += getPlayerTrueDamage(Player.clicks, Player.heroLevel);
    if (currentAllHeroDPS == 0) {
      currentAllHeroDPS = 1e-100;
    }
    Player.currentSalary = currentAllHeroDPS  * (1 + StatBonusGoldAll);
    Player.nextLevelSalaryDiff = (currentAllHeroDPS + Player.nextLeveltrueDamageDiff) * (1 + StatBonusGoldAll);
    Player.efficiency = Player.nextUpgradeCost/(Player.nextLevelSalaryDiff - Player.currentSalary);
    for (var i = 0; i < 30; i++)
    {
      var hero = HeroInfo[i];
      hero.currentSalary = currentAllHeroDPS  * (1 + StatBonusGoldAll);
      hero.nextLevelSalaryDiff = (currentAllHeroDPS + hero.nextLevelDPSDiff) * (1 + StatBonusGoldAll);
      hero.efficiency = hero.nextUpgradeCost/(hero.nextLevelSalaryDiff - hero.currentSalary);
      for (var x = 0; x < hero.skills.length; x++)
      {
        var skill = hero.skills[x];
        updateSkill("AllDamage", skill, hero);
        updateSkill("GoldAll", skill, hero);
        updateSkill("ThisHeroDamage", skill, hero);
        updateSkill("CritDamagePassive", skill, hero);
        updateSkill("TapDamageFromDPS", skill, hero);
        updateSkill("CritChance", skill, hero);
        updateSkill("TapDamagePassive", skill, hero);
        updateSkill("GoldTreasurePassive", skill, hero);
      }
    }
  }

  function updateSkill(bonusType, skill, hero) {
  if (!(skill.isActive) && skill.bonusType == bonusType) {
      skill.isActive = true;
      GetStatBonusAllDamage();
      GetStatBonusAllGold();
      GetStatBonusCritDamagePassive();
      GetStatBonusTapDamageFromDPS();
      GetStatBonusCritChance();
      GetStatBonusTapDamagePassive();
      skill.dps = getPlayerTrueDamage(Player.clicks, Player.heroLevel);;
      for (var y = 0; y < HeroInfo.length; y++) {
        var hero2 = HeroInfo[y];
        if (!(hero2.name == HeroInfo[skill.owner].name)) {
          skill.dps += GetDPSByLevel(hero2, hero2.heroLevel);
        } else {
          if (skill.reqLevel >= hero2.heroLevel) {
            skill.dps += GetDPSByLevel(hero2, skill.reqLevel);
          } else {
            skill.dps += GetDPSByLevel(hero2, hero2.heroLevel);
          }
        }
      }
      skill.isActive = false;
      GetStatBonusAllDamage();
      GetStatBonusAllGold();
      GetStatBonusCritDamagePassive();
      GetStatBonusTapDamageFromDPS();
      GetStatBonusCritChance();
      GetStatBonusTapDamagePassive();
      skill.currentSalary = currentAllHeroDPS  * (1 + StatBonusGoldAll);
      skill.nextLevelSalaryDiff = skill.dps * (1 + StatBonusGoldAll);
      //skill.nextUpgradeCost = GetUpgradeCostByMultiLevel(hero.heroLevel, skill.reqLevel, hero.cost) + (GetUpgradeCostByLevel(skill.reqLevel, hero.cost)*5);
      skill.nextUpgradeCost = GetSkillCost(skill, hero);
      skill.efficiency = skill.nextUpgradeCost/(skill.nextLevelSalaryDiff - skill.currentSalary);
      if(hero.heroLevel == skill.reqLevel) { skill.efficiency = 0; }
    }
  }

  function GetSkillCost(skill, hero) {
    //alert(GetUpgradeCostByLevel(hero.skills[x].reqLevel, hero.cost)*5);
    var num = GetUpgradeCostByMultiLevel(hero.heroLevel, skill.reqLevel, hero.cost);
    var num2 = 0.0;
    for (var x = 0; x < 7; x++)
    {
      if (!(hero.skills[x].isActive))
      {
        num2 += GetUpgradeCostByLevel(hero.skills[x].reqLevel, hero.cost)*5;
      }
      if (hero.skills[x].name == skill.name) { break; }
    }
    return num + num2;
  }

  function Save() {
    //SetSkillsForTable();
    //GetLevels();
    UpdateTables();
    var text = [];
    for (var x = 0; x < HeroInfo.length - 1; x++) {
      var hero = HeroInfo[x]
        , temp = []
        ;
      for (var y = 0; y < hero.skills.length; y++) {
        temp.push(hero.skills[y].isActive);
      }
      text.push({level: HeroInfo[x].heroLevel, skills: temp})
    }
    text.push({level: Player.heroLevel, clicks: Player.clicks})
    for (var y = 0; y < ArtifactInfo.length; y++) {
      text.push({level: ArtifactInfo[y].level})
    }
    $("#savedata").val(JSON.stringify(text));
  }

  function Load() {
    var txt = $("#savedata").val();
    var txt2 = jQuery.parseJSON(txt);
    for (var x = 0; x < 30; x++) {
      for (var y = 0; y < 7; y++) {
        HeroInfo[x].skills[y].isActive = txt2[x].skills[y];
        HeroInfo[x].heroLevel = txt2[x].level;
        $("#Hero"+(x+1)+"skill"+(y+1)).prop("checked", HeroInfo[x].skills[y].isActive);
        $("#Hero"+(x+1)+"heroLevel").val(HeroInfo[x].heroLevel);
      }
    }
    Player.clicks = txt2[30].clicks;
    Player.heroLevel = txt2[30].level;
    $("#player0clicks").val(Player.clicks);
    $("#player0heroLevel").val(Player.heroLevel);
    for (var y = 0; y < ArtifactInfo.length; y++) {
      ArtifactInfo[y].level = txt2[(y+31)].level;
      $("#Artifact"+(y+1)+"level").val(ArtifactInfo[y].level);
    }
    UpdateTables();
  }

  /*
  buildArtifacts();
  UpdateTables();
  */
  function UpdateTables() {
    GetLevels();
    SetSkillsForTable();
    UpdateArtifactsStats();
    GetStatBonusAllDamage();
    GetStatBonusAllGold();
    GetStatBonusCritDamagePassive();
    GetStatBonusTapDamageFromDPS();
    GetStatBonusCritChance();
    GetStatBonusTapDamagePassive();
    UpdateAllHeroesStats();
    printAll();
  }

  function EfficiencyCalculations()
  {
    $("#output").html("");
    UpdateTables();
    GetEfficiency();
  }
//});
