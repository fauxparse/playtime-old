#= require ./controller

class App.Controllers.Stackable extends App.Controller
  init: ->
    @el.addClass "stackable"
    @tappable "[rel=up]", @up

  up: (e) =>
    if e?
      e.preventDefault()
      e.stopPropagation()
    @el.trigger "up"
