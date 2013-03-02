#= require ../stack
#= require ./list

class App.Controllers.Jesters.Jesters extends App.Controllers.Stack
  first: App.Controllers.Jesters.List

  init: ->
    super
    @route "/jesters/:slug/edit", @edit
    @route "/jesters/:slug", @jester
    @route "/jesters", @home

  home: =>
    @popUntil @first

  jester: (params) =>
    @popUntil @first
    if jester = App.Models.Jester.findByAttribute "slug", params.slug
      @push new App.Controllers.Jesters.Jester jester: jester
      jester

  edit: (params) =>
    if jester = App.Models.Jester.findByAttribute "slug", params.slug
      current = @find App.Controllers.Jesters.Jester
      @jester params unless current and current.jester.eql(jester)
      @push new App.Controllers.Jesters.Edit jester: jester
