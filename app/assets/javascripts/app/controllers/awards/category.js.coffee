#= require ../stackable

class App.Controllers.Awards.Category extends App.Controllers.Stackable
  events:
    "tap [rel=new]" : "create"
    "tap [rel=likes]" : "like"

  init: ->
    super
    @render()
    App.Models.Award
      .bind("change refresh", @render)
      .bind("changeID", @changeID)
      .fetch(cache: false)

  render: =>
    awards = App.Models.Award.category @slug
    category = awards[0]?.category or @slug.replace(/-/g, " ")
    @html @view("awards/category")(awards: awards, category: category)
    for award in awards
      @$("[data-id=#{award.id}] button[rel=likes]")
        .find("b").text(award.likes.length).end()
        .toggleClass("liked", App.Models.Jester.current().id in award.likes)

  changeID: (model, oldID, newID) =>
    @$("[data-id=#{oldID}]").attr "data-id", newID
    
  like: (e) ->
    button = $(e.target).closest("[rel=likes]")
    id = button.closest("[data-id]").attr("data-id")
    award = App.Models.Award.exists id
    liked = award.likedBy @currentUser(), !button.hasClass("liked")
    button.toggleClass("liked", liked)
      .find("b").text(award.likes.length)

  create: (e) ->
    awards = App.Models.Award.category @slug
    category = awards[0]?.category or @slug.replace(/-/g, " ")
    @stack.push new App.Controllers.Awards.Edit award: new App.Models.Award(category: category)
