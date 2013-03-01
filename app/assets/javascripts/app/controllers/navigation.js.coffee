class App.Controllers.Navigation extends App.Controller
  tag: "nav"

  init: ->
    @html @view("navigation")()
    @tappable "a", @click

  click: (e) =>
    path = $(e.target).attr("href").replace(/^#/, "")
    if path is Spine.Route.path
      Spine.Route.matchRoute path
    else
      @navigate path, yes
