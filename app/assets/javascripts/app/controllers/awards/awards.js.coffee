#= require ../stack
#= require ./categories

class App.Controllers.Awards.Awards extends App.Controllers.Stack
  first: App.Controllers.Awards.Categories

  init: ->
    super
    @routes
      "/awards/categories/:slug" : @category
      "/awards/categories" : @home
      "/awards/new" : @create
      "/awards/:id/edit" : @edit
      "/awards" : @home
    App.Models.Award.fetch cache: false

  home: =>
    @popUntil @first
    @controllers[0].path = "/awards"

  category: (params) =>
    @home()
    @push new App.Controllers.Awards.Category slug: params.slug

  edit: (params) =>
    if (award = App.Models.Award.exists(params.id)) and award.editableBy(@currentUser())
      @push new App.Controllers.Awards.Edit award: award
    else
      @navigate "/awards", true

  create: (params) =>
    @push new App.Controllers.Awards.Edit award: new App.Models.Award
    