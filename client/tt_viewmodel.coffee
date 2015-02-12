Template.hero.rendered = ->
  vm = new ViewModel(this.data).extend(
    heroLevel: 0
  ).bind @

