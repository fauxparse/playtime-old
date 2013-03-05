#= require ../stackable

class App.Controllers.Awards.Edit extends App.Controllers.Stackable
  elements:
    "form" : "form"

  events:
    "tap [rel=ok]" : "save"

  init: ->
    super
    @html @view("awards/edit")(award: @award, category: @award.category or @category)

  save: =>
    @award.fromForm @form
    @award.save()
    @stack.pop()