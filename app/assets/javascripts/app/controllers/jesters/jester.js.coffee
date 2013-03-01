#= require ../stackable

class App.Controllers.Jesters.Jester extends App.Controllers.Stackable
  init: ->
    @path = "/jesters/#{@jester.slug}"
    @html @view("jesters/jester")(jester: @jester)
    super

