#= require ../stackable

class App.Controllers.Awards.Categories extends App.Controllers.Stackable
  events:
    "tap .categories li" : "select"

  init: ->
    super
    @render()
    App.Models.Award.bind "change refresh", @render

  render: =>
    @html @view("awards/categories")()

  select: (e) ->
    slug = $(e.target).closest("[data-category]").attr("data-category")
    @navigate "/awards/categories/#{slug}", true
