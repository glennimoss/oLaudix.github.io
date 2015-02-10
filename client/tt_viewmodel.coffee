Template.hero.rendered = ->
  ###
  this.vm = new ViewModel(@data).extend(
    heroLevel: 0
  ).bind @
  ###

  console.log "Rendered:", @
  vm = new ViewModel(
    heroLevel: 0
  ).bind @

  console.log "heroLevel:", vm.heroLevel()

