var heroEvolveLevel = 1001.0;
var levelIneffiency = 0.904;
var heroInefficiency = 0.019;
var heroInefficiencySlowDown = 15.0;
var heroUpgradeBase = 1.075;
var evolveCostMultiplier = 10.0;
var dMGScaleDown = 0.1;
var passiveSkillCostMultiplier = 5.0;
var currentAllHeroDPS = 0.0;
var StatBonusAllDamage = 0.0;
var StatBonusGoldAll = 0.0;
var CritDamagePassive = 10.0;
var TapDamageFromDPS = 0.0;
var CritChance = 0.02;
var TapDamagePassive = 0.0;
var artifactBonusDamage = 0.0;
//var ArtifactDamageBoost = 0.0;

function buildArtifacts() {
  //$("#artifacttable").append("<tr><th>Artifact</th><th>Max Level</th><th>Bonus Type</th><th>Bonus Strength</th><th>Damage Bonus</th><th>Upgrade Cost</th><th>Level</th></tr>");
  $("#artifacttable").append("<tr><th>Artifact</th><th>Bonus Type</th><th>Bonus Strength</th><th>Damage Bonus</th><th>Upgrade Cost</th><th>Level</th></tr>\n");
  for (var y = 0; y < ArtifactInfo.length; y++) {
    var tr2 = ArtifactInfo[y].targetBox = $("<tr></tr>");
    tr2.append($("<td></td>").append(ArtifactInfo[y].name).attr("id", ArtifactInfo[y].artifactID+"name"));
    tr2.append($("<td></td>").append(ArtifactInfo[y].bonusType).attr("id", ArtifactInfo[y].artifactID+"bonusType").attr("style", "font-size:10px"));
    tr2.append($("<td></td>").append(ArtifactInfo[y].bonusPerLevel*100+"%").attr("id", ArtifactInfo[y].artifactID+"artifactBonus"));
    tr2.append($("<td></td>").append(ArtifactInfo[y].DamageBonus*100+"%").attr("id", ArtifactInfo[y].artifactID+"DamageBonus"));
    tr2.append($("<td></td>").append(getArtifactUpgradeCost(ArtifactInfo[y])).attr("id", ArtifactInfo[y].artifactID+"upgradeCost"));
    if (ArtifactInfo[y].maxLevel > 0) {
      tr2.append(
        $("<td></td>").append(
                        $("<input></input>").attr("type", "text").val(0)
                                            .attr("id", ArtifactInfo[y].artifactID+"level")
                      )
                      .append("/" + ArtifactInfo[y].maxLevel)
      );
    } else {
      tr2.append($("<td></td>").append($("<input></input>").attr("type", "text").val(0).attr("id", ArtifactInfo[y].artifactID+"level")));
    }
    $("#artifacttable").append(tr2);
  }
}

function GetHeroBaseCost (purchaseCost, heroLevel) {
    iLevel = -1;
    if (iLevel == -1) {
      iLevel = heroLevel;
    }
    if (heroLevel >= (heroEvolveLevel - 1)) {
      purchaseCost *= evolveCostMultiplier;
    }
    return purchaseCost;
}

function accumulateStatBonus (bonusType) {
  var num = 0.0;
  for (var y = 0; y < heroList.length; y++) {
    num += accumulateHeroStatBonus(HeroInfo[heroList[y]], bonusType);
  }
  return num;
}

function accumulateHeroStatBonus (hero, bonusType) {
  var num = 0.0;
  for (var x = 0; x < hero.skills.length; x++) {
    if (hero.skills[x].isActive && hero.skills[x].bonusType == bonusType) {
      num = num + hero.skills[x].magnitude;
    }
  }
  return num;
}

currentPassiveThisHeroDamage = function (hero) { return accumulateHeroStatBonus(hero, "ThisHeroDamage"); }

/*
function currentPassiveThisHeroDamage (hero) {
  var num = 0.0;
  for (var x = 0; x < 7; x++) {
    if (hero.skills[x].isActive && hero.skills[x].bonusType=="ThisHeroDamage") {
      num = num + hero.skills[x].magnitude;
    }
  }
  return num;
}
*/

function GetStatBonusAllDamage () {
  StatBonusAllDamage = accumulateStatBonus("AllDamage");

  /*
  for (var y = 0; y < 30; y++) {
    var hero = HeroInfo[heroList[y]];
    for (var x = 0; x < 7; x++) {
      if (hero.skills[x].isActive && hero.skills[x].bonusType=="AllDamage") {
        StatBonusAllDamage = StatBonusAllDamage + hero.skills[x].magnitude;
      }
    }
  }
  */
}

function GetStatBonusAllGold () {
  StatBonusGoldAll = 0.0 + ArtifactInfo[19].currentBonus;

  StatBonusGoldAll += accumulateStatBonus("GoldAll");
  /*
  for (var y = 0; y < 30; y++) {
    var hero = HeroInfo[heroList[y]];
    for (var x = 0; x < 7; x++) {
      if (hero.skills[x].isActive && hero.skills[x].bonusType == "GoldAll") {
        StatBonusGoldAll = StatBonusGoldAll + hero.skills[x].magnitude;
      }
    }
  }
  */
}

function GetStatBonusTapDamageFromDPS () {
  TapDamageFromDPS = accumulateStatBonus("TapDamageFromDPS");
  /*
  for (var y = 0; y < 30; y++) {
    var hero = HeroInfo[heroList[y]];
    for (var x = 0; x < 7; x++) {
      if (hero.skills[x].isActive && hero.skills[x].bonusType=="TapDamageFromDPS") {
        TapDamageFromDPS = TapDamageFromDPS + hero.skills[x].magnitude;
      }
    }
  }
  */
}

function GetStatBonusCritChance() {
  CritChance = 0.02 + ArtifactInfo[3].currentBonus;
  CritChance += accumulateStatBonus("CritChance");
  /*
  for (var y = 0; y < 30; y++) {
    var hero = HeroInfo[heroList[y]];
    for (var x = 0; x < 7; x++) {
      if (hero.skills[x].isActive && hero.skills[x].bonusType=="CritChance") {
        CritChance = CritChance + hero.skills[x].magnitude;
      }
    }
  }
  */
}

function GetStatBonusCritDamagePassive() {
  CritDamagePassive = 10.0 + 10 * accumulateStatBonus("CritDamagePassive");
  /*
  for (var y = 0; y < 30; y++) {
    var hero = HeroInfo[heroList[y]];
    for (var x = 0; x < 7; x++) {
      if (hero.skills[x].isActive && hero.skills[x].bonusType=="CritDamagePassive") {
        CritDamagePassive = CritDamagePassive + (hero.skills[x].magnitude*10);
      }
    }
  }
  */
  CritDamagePassive = CritDamagePassive * (1 + ArtifactInfo[16].currentBonus)
}

function GetStatBonusTapDamagePassive() {
  TapDamagePassive = accumulateStatBonus("TapDamagePassive");
  /*
  for (var y = 0; y < 30; y++) {
    var hero = HeroInfo[heroList[y]];
    for (var x = 0; x < 7; x++) {
      if (hero.skills[x].isActive && hero.skills[x].bonusType=="TapDamagePassive") {
        TapDamagePassive = TapDamagePassive + hero.skills[x].magnitude;
      }
    }
  }
  */
}

function GetEfficiency() {
  var output = [];
    var levels = [];
  var text = "";
  var best = 0;
  //var bestskill = [0,0]
  var bestskill = HeroInfo[heroList[0]].skills[0];
  var test = 0;
  for (var x = 0; x < 10000; x++) {
    //best = 30;
    for (i = 0; i < 30; i++) {
      if (HeroInfo[heroList[i]].isActive) {
        var eff = HeroInfo[heroList[i]].efficiency;
        var beff = HeroInfo[heroList[best]].efficiency;
        if (eff < beff) {
          //oldbest = best;
          best = i;
        }
        for (var h = 0; h < 7; h++) {
          if (!(HeroInfo[heroList[i]].skills[h].isActive)) {
            var eff = HeroInfo[heroList[i]].skills[h].efficiency;
            var beff = bestskill.efficiency;
            if (eff < beff) {
              bestskill = HeroInfo[heroList[i]].skills[h];
            }
          }
        }
      }
      var eff = HeroInfo[heroList[30]].efficiency;
      var beff = HeroInfo[heroList[best]].efficiency;
      if (eff < beff) {
        //oldbest = best;
        best = 30;
      }
    }
    //alert(bestskill.name);
    if (bestskill.efficiency < HeroInfo[heroList[best]].efficiency) {
      if (HeroInfo[bestskill.owner].heroLevel == bestskill.reqLevel) {
        bestskill.isActive = true;
        //HeroInfo[bestskill.owner].heroLevel = bestskill.reqLevel;
        if (x==0) {
          output.push({name: HeroInfo[bestskill.owner].name, level: HeroInfo[bestskill.owner].heroLevel});
          output.push({name: bestskill.name + " - " + bestskill.reqLevel, level: HeroInfo[bestskill.owner].name});
        } else {
          if (output[output.length-1].name == HeroInfo[bestskill.owner].name) {
            output[output.length-1].level = HeroInfo[bestskill.owner].heroLevel;
            output.push({name: bestskill.name + " - " + bestskill.reqLevel, level: HeroInfo[bestskill.owner].name});
          } else {
            output.push({name: HeroInfo[bestskill.owner].name, level: HeroInfo[bestskill.owner].heroLevel});
            output.push({name: bestskill.name + " - " + bestskill.reqLevel, level: HeroInfo[bestskill.owner].name});
          }
        }
        bestskill.efficiency = 1000000;
      } else {
        HeroInfo[bestskill.owner].heroLevel += 1;
        if (x==0) {
          output.push({name: HeroInfo[bestskill.owner].name, level: HeroInfo[bestskill.owner].heroLevel});
        } else {
          if (output[output.length-1].name == HeroInfo[bestskill.owner].name) {
            output[output.length-1].level = HeroInfo[bestskill.owner].heroLevel;
          } else {
            output.push({name: HeroInfo[bestskill.owner].name, level: HeroInfo[bestskill.owner].heroLevel});
          }
        }
      }
    } else {
      HeroInfo[heroList[best]].heroLevel += 1;
      if (x==0) {
        output.push({name: HeroInfo[heroList[best]].name, level: HeroInfo[heroList[best]].heroLevel});
      } else {
        if (output[output.length-1].name == HeroInfo[heroList[best]].name) {
          output[output.length-1].level = HeroInfo[heroList[best]].heroLevel;
        } else {
          output.push({name: HeroInfo[heroList[best]].name, level: HeroInfo[heroList[best]].heroLevel});
        }
      }
    }
    GetStatBonusAllDamage();
    GetStatBonusAllGold();
    GetStatBonusCritDamagePassive();
    GetStatBonusTapDamageFromDPS();
    GetStatBonusCritChance();
    GetStatBonusTapDamagePassive();
    SetSkillsForEfficiency();
    UpdateAllHeroesStats();
    if (output.length > parseInt($("#numberofpredictions").val())) {
      $("#output").html("");
      text = "";
      //text += "<table id=\"resulttbl\" class=\"table table-striped\"><tbody>";
      //text += "<tr><th>Name</th><th>Level</th></tr>"
      for (var i = 0; i < output.length; i++) {
        //if (output[i+1].name == output[i].name) { continue; }
        //text += "<tr><td>" + output[i].name + "</td><td>" + output[i].level + "</td></tr>";
        text += output[i].name + " - " + output[i].level + "<br>";
      }
      //text += "</tbody></table>";
      $("#output").html(text);
      //alert(test);
      break;
    }
  }
}

function GetUpgradeCostByMultiLevel(iLevelstart, iLevelfinish, purchaseCost) {
  var total = 0.0;
  for (var i = iLevelstart; i < iLevelfinish; i++) {
    total += GetUpgradeCostByLevel(i, purchaseCost);
  }
  return total;
}

function printAll() {
  for (var i = 0; i < 30; i++) {
    printHeroInfo(HeroInfo[heroList[i]]);
  }
  for (var j = 0; j < ArtifactInfo.length; j++) {
    printArtifactInfo(ArtifactInfo[j]);
  }
  $("#player0nextUpgradeCost").html(numberFormat(HeroInfo[heroList[30]].nextUpgradeCost));
  //$("#player0currentDPS").html(numberFormat(HeroInfo[heroList[30]].currentDamage));
  //$("#player0nextLevelDPSDiff").html("+ "+numberFormat(HeroInfo[heroList[30]].nextLevelDMGDiff));
  if (HeroInfo[heroList[30]].currentDamage > 1000000) {
    $("#player0currentDPS").html(HeroInfo[heroList[30]].currentDamage.toExponential(3));
  } else {
    $("#player0currentDPS").html(Math.floor(HeroInfo[heroList[30]].currentDamage));
  }
  if (HeroInfo[heroList[30]].nextLevelDMGDiff > 1000000) {
    $("#player0nextLevelDPSDiff").html("+ "+HeroInfo[heroList[30]].nextLevelDMGDiff.toExponential(3));
  } else {
    $("#player0nextLevelDPSDiff").html("+ "+Math.floor(HeroInfo[heroList[30]].nextLevelDMGDiff));
  }
  $("#playerdata").html(
            "Total Damage: " + numberFormat(HeroInfo[heroList[30]].trueDamage) + "<br>" +
            "Next Level Total Damage: " + numberFormat(HeroInfo[heroList[30]].nextLeveltrueDamageDiff) + "<br>" +
            "Min crit dmg: " + numberFormat(HeroInfo[heroList[30]].MinCritDamage) + "<br>" +
            "Max crit dmg: " + numberFormat(HeroInfo[heroList[30]].MaxCritDamage) + "<br>" +
            "Avg crit dmg: " + numberFormat(HeroInfo[heroList[30]].AvgCritDamage) + "<br>" +
            "Crit dmg: " + numberFormat(HeroInfo[heroList[30]].CritDamage) + "<br>" +
            "<br>" +
            "All Damage Bonus: " + StatBonusAllDamage + "<br>" +
            "All Gold Bonus: " + StatBonusGoldAll + "<br>" +
            "Crit Damage Bonus: " + CritDamagePassive + "<br>" +
            "Tap Dmg from DPS Bonus: " + TapDamageFromDPS + "<br>" +
            "Crit Chance Bonus: " + CritChance + "<br>" +
            "Tap Damage Bonus: " + TapDamagePassive + "<br>" +
            "<br>" +
            "Total DPS: " + numberFormat(currentAllHeroDPS) + "<br>"
            );
}

function GetSkills() {
  for (var x = 1; x < 31; x++) {
    for (var y = 1; y < 8; y++) {
      HeroInfo[heroList[x-1]].skills[y-1].isActive = $("#Hero"+x+"skill"+y).is(":checked");
    }
  }
}

function SetSkillsForTable() {
  for (var x = 1; x < 31; x++) {
    for (var y = 1; y < 8; y++) {
      if (HeroInfo[heroList[x-1]].skills[y-1].reqLevel < HeroInfo[heroList[x-1]].heroLevel) {
        HeroInfo[heroList[x-1]].skills[y-1].isActive = true;
        $("#Hero"+x+"skill"+y).prop("checked", HeroInfo[heroList[x-1]].skills[y-1].isActive);
      } else if (HeroInfo[heroList[x-1]].skills[y-1].reqLevel > HeroInfo[heroList[x-1]].heroLevel) {
        HeroInfo[heroList[x-1]].skills[y-1].isActive = false;
        $("#Hero"+x+"skill"+y).prop("checked", HeroInfo[heroList[x-1]].skills[y-1].isActive);
      }
      HeroInfo[heroList[x-1]].skills[y-1].isActive = $("#Hero"+x+"skill"+y).is(":checked");
      //$("#Hero1skill1").prop("checked", HeroInfo[heroList[0]].skills[0].isActive);
    }
  }
}
function SetSkillsForEfficiency() {
  for (var x = 1; x < 31; x++) {
    for (var y = 1; y < 8; y++) {
      if (HeroInfo[heroList[x-1]].skills[y-1].reqLevel < HeroInfo[heroList[x-1]].heroLevel) {
        HeroInfo[heroList[x-1]].skills[y-1].isActive = true;
      }
      //$("#Hero"+x+"skill"+y).prop("checked", HeroInfo[heroList[x-1]].skills[y-1].isActive);
      //$("#Hero1skill1").prop("checked", HeroInfo[heroList[0]].skills[0].isActive);
    }
  }
}

function GetLevels() {
  for (var i = 0; i < 30; i++) {
    HeroInfo[heroList[i]].heroLevel = parseInt($("#Hero"+(i+1)+"heroLevel").val());
  }
  HeroInfo[heroList[30]].heroLevel = parseInt($("#player0heroLevel").val());
  HeroInfo[heroList[30]].clicks = parseInt($("#player0clicks").val());
  for (var j = 0; j < ArtifactInfo.length; j++) {
    ArtifactInfo[j].level = parseInt($("#"+ArtifactInfo[j].artifactID+"level").val());
    if (ArtifactInfo[j].level > parseInt(ArtifactInfo[j].maxLevel) && parseInt(ArtifactInfo[j].maxLevel) > 0) {
      ArtifactInfo[j].level = parseInt(ArtifactInfo[j].maxLevel);
      $("#"+ArtifactInfo[j].artifactID+"level").val(ArtifactInfo[j].maxLevel);
    }
  }
}

var _Units = ["", "K", "M", "B", "T"];
var _BigUnitStart = "a".charCodeAt(0);
var _WayTooBigUnit = "z".charCodeAt(0);
// Use en-US so locale doesn't affect logic.
var _ToStr = Intl.NumberFormat("en-US", {useGrouping: false, maximumFractionDigits: 0});
var _PrettyFmt = Intl.NumberFormat(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2});
function numberFormat (number) {
  var num = number
      // We're converting to a string because Math.log10 can't be trusted
      // e.g. Math.log10(1e15) = 14.999999999999998
    , exp = Math.floor((_ToStr.format(num).length - 1) / 3)
    , unit
    ;
  if (exp == 0) {
    return num.toString();
  }
  if (exp < _Units.length) {
    unit = _Units[exp];
  } else {
    var unitCode = _BigUnitStart + exp - _Units.length;
    unit = String.fromCharCode(unitCode, unitCode);
    if (unitCode > _WayTooBigUnit) {
      unit = "e" + (exp*3);
    }
  }
  num = num / Math.pow(1000, exp);
  return _PrettyFmt.format(num) + unit
}
