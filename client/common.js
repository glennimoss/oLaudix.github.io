TT.heroEvolveLevel = 1001.0;
TT.levelIneffiency = 0.904;
TT.heroInefficiency = 0.019;
TT.heroInefficiencySlowDown = 15.0;
TT.heroUpgradeBase = 1.075;
TT.evolveCostMultiplier = 10.0;
TT.dMGScaleDown = 0.1;
TT.passiveSkillCostMultiplier = 5.0;
TT.currentAllHeroDPS = 0.0;
TT.StatBonusAllDamage = 0.0;
TT.StatBonusGoldAll = 0.0;
TT.CritDamagePassive = 10.0;
TT.TapDamageFromDPS = 0.0;
TT.CritChance = 0.02;
TT.TapDamagePassive = 0.0;
TT.artifactBonusDamage = 0.0;

TT.GetHeroBaseCost = function (purchaseCost, heroLevel) {
    iLevel = -1;
    if (iLevel == -1) {
      iLevel = heroLevel;
    }
    if (heroLevel >= (TT.heroEvolveLevel - 1)) {
      purchaseCost *= TT.evolveCostMultiplier;
    }
    return purchaseCost;
}

TT.GetEfficiency = function () {
  var output = [];
    var levels = [];
  var text = "";
  var best = 0;
  //var bestskill = [0,0]
  var bestskill = TT.HeroInfo[0].skills[0];
  var test = 0;
  for (var x = 0; x < 10000; x++) {
    //best = 30;
    for (i = 0; i < 30; i++) {
      if (TT.HeroInfo[i].isActive) {
        var eff = TT.HeroInfo[i].efficiency;
        var beff = TT.HeroInfo[best].efficiency;
        if (eff < beff) {
          //oldbest = best;
          best = i;
        }
        for (var h = 0; h < TT.HeroInfo[i].skills.length; h++) {
          if (!(TT.HeroInfo[i].skills[h].isActive)) {
            var eff = TT.HeroInfo[i].skills[h].efficiency;
            var beff = bestskill.efficiency;
            if (eff < beff) {
              bestskill = TT.HeroInfo[i].skills[h];
            }
          }
        }
      }
      var eff = TT.Player.efficiency;
      var beff = TT.HeroInfo[best].efficiency;
      if (eff < beff) {
        //oldbest = best;
        best = 30;
      }
    }
    //alert(bestskill.name);
    if (bestskill.efficiency < TT.HeroInfo[best].efficiency) {
      if (TT.HeroInfo[bestskill.owner].heroLevel == bestskill.reqLevel) {
        bestskill.isActive = true;
        //TT.HeroInfo[bestskill.owner].heroLevel = bestskill.reqLevel;
        if (x==0) {
          output.push({name: TT.HeroInfo[bestskill.owner].name, level: TT.HeroInfo[bestskill.owner].heroLevel});
          output.push({name: bestskill.name + " - " + bestskill.reqLevel, level: TT.HeroInfo[bestskill.owner].name});
        } else {
          if (output[output.length-1].name == TT.HeroInfo[bestskill.owner].name) {
            output[output.length-1].level = TT.HeroInfo[bestskill.owner].heroLevel;
            output.push({name: bestskill.name + " - " + bestskill.reqLevel, level: TT.HeroInfo[bestskill.owner].name});
          } else {
            output.push({name: TT.HeroInfo[bestskill.owner].name, level: TT.HeroInfo[bestskill.owner].heroLevel});
            output.push({name: bestskill.name + " - " + bestskill.reqLevel, level: TT.HeroInfo[bestskill.owner].name});
          }
        }
        bestskill.efficiency = 1000000;
      } else {
        TT.HeroInfo[bestskill.owner].heroLevel += 1;
        if (x==0) {
          output.push({name: TT.HeroInfo[bestskill.owner].name, level: TT.HeroInfo[bestskill.owner].heroLevel});
        } else {
          if (output[output.length-1].name == TT.HeroInfo[bestskill.owner].name) {
            output[output.length-1].level = TT.HeroInfo[bestskill.owner].heroLevel;
          } else {
            output.push({name: TT.HeroInfo[bestskill.owner].name, level: TT.HeroInfo[bestskill.owner].heroLevel});
          }
        }
      }
    } else {
      TT.HeroInfo[best].heroLevel += 1;
      if (x==0) {
        output.push({name: TT.HeroInfo[best].name, level: TT.HeroInfo[best].heroLevel});
      } else {
        if (output[output.length-1].name == TT.HeroInfo[best].name) {
          output[output.length-1].level = TT.HeroInfo[best].heroLevel;
        } else {
          output.push({name: TT.HeroInfo[best].name, level: TT.HeroInfo[best].heroLevel});
        }
      }
    }
    TT.GetStatBonusAllDamage();
    TT.GetStatBonusAllGold();
    TT.GetStatBonusCritDamagePassive();
    TT.GetStatBonusTapDamageFromDPS();
    TT.GetStatBonusCritChance();
    TT.GetStatBonusTapDamagePassive();
    TT.SetSkillsForEfficiency();
    TT.UpdateAllHeroesStats();
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

TT.GetUpgradeCostByMultiLevel = function (iLevelstart, iLevelfinish, purchaseCost) {
  var total = 0.0;
  for (var i = iLevelstart; i < iLevelfinish; i++) {
    total += TT.GetUpgradeCostByLevel(i, purchaseCost);
  }
  return total;
}

TT.GetSkills = function () {
  for (var x = 1; x < 31; x++) {
    for (var y = 1; y < 8; y++) {
      TT.HeroInfo[x-1].skills[y-1].isActive = $("#Hero"+x+"skill"+y).is(":checked");
    }
  }
}

TT.SetSkillsForEfficiency = function () {
  for (var x = 1; x < 31; x++) {
    for (var y = 1; y < 8; y++) {
      if (TT.HeroInfo[x-1].skills[y-1].reqLevel < TT.HeroInfo[x-1].heroLevel) {
        TT.HeroInfo[x-1].skills[y-1].isActive = true;
      }
      //$("#Hero"+x+"skill"+y).prop("checked", TT.HeroInfo[x-1].skills[y-1].isActive);
      //$("#Hero1skill1").prop("checked", TT.HeroInfo[0].skills[0].isActive);
    }
  }
}

