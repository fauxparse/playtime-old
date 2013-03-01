#= require ./controller

class App.Controllers.Application extends App.Controller
  sections: {}

  elements:
    ".sections" : "container"

  events:
    "up .stackable:first-child" : "showNavigation"

  init: ->
    @append new App.Controllers.Navigation
    @append $("<div>").addClass("sections screen").append("<div class=\"edge\">")

    @addSection "shows", App.Controllers.Shows.Shows
    @addSection "availability", App.Controllers.Availability.Availability
    @addSection "jesters", App.Controllers.Jesters.Jesters
    @addSection "calendar", new App.Controllers.Availability.Availability first: App.Controllers.Availability.Months

    @tappable ".edge", @hideNavigation
    Spine.Route.bind "change", @change
    Spine.Route.bind "navigate", @navigate
    Spine.Route.setup trigger: true

  addSection: (name, controller) ->
    controller = new controller unless controller instanceof Spine.Controller
    @sections[name] = controller
    controller.el.attr("data-section", name).hide().appendTo @container

  section: (name) ->
    if controller = @sections[name]
      unless name is @current and @container.hasClass("in")
        controller.el.show()
          .siblings("section").hide().end()
        @current = name
      @container.addClass "in"

  change: (route, path) =>
    @navigate path

  navigate: (path) =>
    @section path.split("/", 3).slice(1, 2).pop()

  showNavigation: =>
    @container.removeClass "in"

  hideNavigation: =>
    @container.addClass "in"