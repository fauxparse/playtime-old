#= require ../stack
#= require ./list

class App.Controllers.Jesters.Jesters extends App.Controllers.Stack
  first: App.Controllers.Jesters.List

  init: ->
    super
    @route "/jesters/:slug", @jester
    @route "/jesters", @home

  home: =>
    @popUntil @first

  jester: (params) =>
    @popUntil @first
    if jester = App.Models.Jester.findByAttribute "slug", params.slug
      @push new App.Controllers.Jesters.Jester jester: jester
      @navigate "/jesters/#{params.slug}", false