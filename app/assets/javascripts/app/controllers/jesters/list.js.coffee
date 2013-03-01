#= require ../stackable

class App.Controllers.Jesters.List extends App.Controllers.Stackable
  elements:
    ".list" : "list"

  events:
    "tap li" : "zoom"

  path: "/jesters"

  init: ->
    super
    @html @view("jesters/list")()
    @render()
    App.Models.Jester.bind "change", @render

  render: =>
    @list.empty()
    for jester in App.Models.Jester.sorted()
      $(@view("jesters/row")(jester: jester))
        .toggleClass("active", jester.active)
        .appendTo(@list)

  zoom: (e) =>
    slug = $(e.target).closest("[data-slug]").attr("data-slug")
    @navigate "/jesters/#{slug}", true