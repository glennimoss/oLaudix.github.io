Template.hero.rendered = ->
  em =
    heroLevel: 0
    nextUpgradeCost: 0
    currentDPS: 0
    nextLevelDPSDiff: 0
  for skill in this.data.skills
    em["skill#{skill.skillID}"] = false

  TT.vm.push(new ViewModel(this.data).extend(em).bind @)
