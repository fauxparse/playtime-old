#= require ../stackable

class App.Controllers.Awards.Category extends App.Controllers.Stackable
  events:
    "tap [rel=likes]" : "like"

  init: ->
    super
    @render()
    App.Models.Award.bind("change refresh", @render).fetch cache: false

  render: =>
    awards = App.Models.Award.category @slug
    category = awards[0]?.category or @slug.replace(/-/g, " ")
    @html @view("awards/category")(awards: awards, category: category)
    for award in awards
      @$("[data-id=#{award.id}] button[rel=likes]")
        .find("b").text(award.likes.length).end()
        .toggleClass("liked", App.Models.Jester.current().id in award.likes)
    
  like: (e) ->
    button = $(e.target).closest("[rel=likes]")
    id = button.closest("[data-id]").attr("data-id")
    award = App.Models.Award.exists id
    liked = award.likedBy @currentUser(), !button.hasClass("liked")
    button.toggleClass("liked", liked)
      .find("b").text(award.likes.length)