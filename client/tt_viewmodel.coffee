Template.hero.rendered = ->
  hero = @data
  TT.vm.heroes.push(new ViewModel(this.data).extend(
    nextLevelDpsDiff: -> TT.numberFormat(hero.getDps(hero.level + 1) - hero.getDps())
  ).bind @)

Template.skillbox.rendered = ->
  new ViewModel(
    skill: @data
    isActive: -> @skill().isActive
  ).bind @

Template.artifact.rendered = ->
  artifact = @data
  TT.vm.artifacts.push(new ViewModel(
    getBonus: -> artifact.getBonus()
    getDamage: -> artifact.getDamage()
    level: -> artifact.level
  ).bind @)
