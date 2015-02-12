TT.getArtifactRelicsSpent = function (artifact) {
  var num = 0.0;
  for (var x = 1; x < artifact.level; x++)
  {
    var num1 = artifact.CostCoEff * Math.pow(x + 1, artifact.CostExpo);
    var num2 = Math.round(num1);
    num += num2;
  }
  return num;
}

TT.GetDPSByLevel = function (hero, level) {
    var num3 = 0.0;
    if (TT.IsEvolved(level))
    {
      num3 = Math.pow(TT.levelIneffiency, (level - TT.heroEvolveLevel)) * Math.pow((1.0 - (TT.heroInefficiency * TT.heroInefficiencySlowDown)), (hero.heroID + 30));
    }
    else
    {
      num3 = Math.pow(TT.levelIneffiency, (level - 1)) * Math.pow((1.0 - (TT.heroInefficiency * Math.min(hero.heroID, TT.heroInefficiencySlowDown))), hero.heroID);
    }
    var num4 = 0.0;
    if (TT.IsEvolved(level))
    {
      num4 = (((TT.GetUpgradeCostByLevel(level - 1, hero.cost) * (Math.pow(TT.heroUpgradeBase, (level - (TT.heroEvolveLevel - 1))) - 1.0)) / ((TT.heroUpgradeBase - 1.0))) * num3) * TT.dMGScaleDown;
    }
    else
    {
      num4 = (((TT.GetUpgradeCostByLevel(level - 1, hero.cost) * (Math.pow(TT.heroUpgradeBase, level) - 1.0)) / ((TT.heroUpgradeBase - 1.0))) * num3) * TT.dMGScaleDown;
    }
    return (num4 * (1.0 + TT.currentPassiveThisHeroDamage(hero) + TT.StatBonusAllDamage)) * (1.0 + TT.artifactBonusDamage);
}

TT.IsEvolved = function (iLevel) {
  return (iLevel >= TT.heroEvolveLevel);
}

TT.GetUpgradeCostByLevel = function (iLevel, purchaseCost) {
    var num = 0.0;
    num = TT.GetHeroBaseCost(purchaseCost, iLevel) * Math.pow(TT.heroUpgradeBase, iLevel);
    var a = num * (1.0 + TT.ArtifactInfo[23].currentBonus);
    return Math.ceil(a);
}

TT.UpdatePlayerStats = function () {
  TT.Player.currentDamage = TT.GetAttackDamageByLevel(TT.Player.heroLevel);
  TT.Player.nextLevelDMGDiff = TT.GetAttackDamageByLevel(TT.Player.heroLevel + 1) - TT.Player.currentDamage;
  TT.Player.nextUpgradeCost = TT.GetPlayerUpgradeCostByLevel(TT.Player.heroLevel);
  TT.Player.MinCritDamage = TT.Player.currentDamage * TT.CritDamagePassive * 0.3;
  TT.Player.MaxCritDamage = TT.Player.currentDamage * TT.CritDamagePassive;
  TT.Player.AvgCritDamage = TT.Player.currentDamage * TT.CritDamagePassive * 0.65;
  TT.Player.CritDamage = ((TT.CritChance*100*TT.Player.AvgCritDamage) + ((1-TT.CritChance)*100*TT.Player.currentDamage))/100;
  TT.Player.trueDamage = TT.getPlayerTrueDamage(TT.Player.clicks, TT.Player.heroLevel);
  TT.Player.nextLeveltrueDamageDiff = TT.getPlayerTrueDamage(TT.Player.clicks, TT.Player.heroLevel + 1) - TT.Player.trueDamage;
}

TT.getPlayerTrueDamage = function (clicks, iLevel) {
  var num1 = TT.GetAttackDamageByLevel(iLevel);
  var num2 = num1 * TT.CritDamagePassive * 0.65;
  var num3 = ((TT.CritChance*100*num2) + ((1-TT.CritChance)*100*num1))/100;
  var num4 = num3 * clicks;
  return num4;
}

TT.GetAttackDamageByLevel = function (iLevel) {
    var num = iLevel * Math.pow(1.05, iLevel);
    var num3 = TT.TapDamagePassive;
    var num4 = TT.TapDamageFromDPS * TT.currentAllHeroDPS;
    //var num5 = PlayerModel.instance.GetStatBonus(BonusType.TapDamageActive);
  var num5 = 0;
    var num7 = TT.ArtifactInfo[28].currentBonus;
    //var num8 = (((((num * (1.0 + statBonus)) + num4) * (1.0 + num3)) * (1.0 + num5)) * (1.0 + artifactDamageBonus)) * (1.0 + num7);
  var num8 = (((((num * (1.0 + TT.StatBonusAllDamage)) + num4) * (1.0 + num3)) * (1.0 + num5)) * (1.0 + TT.artifactBonusDamage)) * (1.0 + num7);
  //alert(num8);
    if (num8 <= 1.0)
    {
        num8 = 1.0;
    }
    return num8;
}

TT.GetPlayerUpgradeCostByLevel = function (iLevel) {
    var num = Math.min(25, 3 + iLevel) * Math.pow(1.074, iLevel);
    var a = num * (1.0 + TT.ArtifactInfo[23].currentBonus);
    return Math.ceil(a);
}

TT.GetSkillCost = function (skill, hero) {
  //alert(TT.GetUpgradeCostByLevel(hero.skills[x].reqLevel, hero.cost)*5);
  var num = TT.GetUpgradeCostByMultiLevel(hero.heroLevel, skill.reqLevel, hero.cost);
  var num2 = 0.0;
  for (var x = 0; x < 7; x++)
  {
    if (!(hero.skills[x].isActive))
    {
      num2 += TT.GetUpgradeCostByLevel(hero.skills[x].reqLevel, hero.cost)*5;
    }
    if (hero.skills[x].name == skill.name) { break; }
  }
  return num + num2;
}

TT.Save = function () {
  //TT.SetSkillsForTable();
  //TT.GetLevels();
  TT.UpdateTables();
  var text = [];
  for (var x = 0; x < TT.HeroInfo.length - 1; x++) {
    var hero = TT.HeroInfo[x]
      , temp = []
      ;
    for (var y = 0; y < hero.skills.length; y++) {
      temp.push(hero.skills[y].isActive);
    }
    text.push({level: TT.HeroInfo[x].heroLevel, skills: temp})
  }
  text.push({level: TT.Player.heroLevel, clicks: TT.Player.clicks})
  for (var y = 0; y < TT.ArtifactInfo.length; y++) {
    text.push({level: TT.ArtifactInfo[y].level})
  }
  $("#savedata").val(JSON.stringify(text));
}

TT.Load = function () {
  var txt = $("#savedata").val();
  var txt2 = jQuery.parseJSON(txt);
  for (var x = 0; x < 30; x++) {
    for (var y = 0; y < 7; y++) {
      TT.HeroInfo[x].skills[y].isActive = txt2[x].skills[y];
      TT.HeroInfo[x].heroLevel = txt2[x].level;
      $("#Hero"+(x+1)+"skill"+(y+1)).prop("checked", TT.HeroInfo[x].skills[y].isActive);
      $("#Hero"+(x+1)+"heroLevel").val(TT.HeroInfo[x].heroLevel);
    }
  }
  TT.Player.clicks = txt2[30].clicks;
  TT.Player.heroLevel = txt2[30].level;
  $("#player0clicks").val(TT.Player.clicks);
  $("#player0heroLevel").val(TT.Player.heroLevel);
  for (var y = 0; y < TT.ArtifactInfo.length; y++) {
    TT.ArtifactInfo[y].level = txt2[(y+31)].level;
    $("#Artifact"+(y+1)+"level").val(TT.ArtifactInfo[y].level);
  }
  TT.UpdateTables();
}

TT.EfficiencyCalculations = function ()
{
  $("#output").html("");
  TT.UpdateTables();
  TT.GetEfficiency();
}


$(TT.UpdateTables);
