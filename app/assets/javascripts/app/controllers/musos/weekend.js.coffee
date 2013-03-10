class App.Controllers.Musos.Weekend extends App.Controller
  elements:
    ".musos" : "lists"

  events:
    "tap .musos li": "toggle"

  init: ->
    @friday   = App.Controllers.Availability.Weekends.fromIndex @index
    @saturday = new Date(@friday.getTime() + Date.DAY)
    @el.addClass("weekend")
    @html @view("musos/weekend")(friday: @friday, saturday: @saturday)
    @load().done @populate
    @bind "release", @unbindShows

  unbindShows: =>
    for show in @shows
      show.unbind "update", @refreshShow

  load: ->
    $.when(
      App.Models.Show.day(@friday.toArray()...),
      App.Models.Show.day(@saturday.toArray()...)
    )

  populate: (shows...) =>
    @shows = shows.slice 0
    show.bind("update", @refreshShow) for show in @shows
    @refresh()

  refreshShow: (show, options = {}) =>
    unless options.from is "musos"
      @refresh()

  refresh: =>
    @lists.empty()
    for muso in App.Models.Jester.musos() when muso.active
      $("<li>", "data-id": muso.id, text: muso.toString()).appendTo @lists
    for show, i in @shows
      @$("header h3").eq(i).text show.date().format("%A %d")
      show.cast().each (jester, role) =>
        if role is "muso"
          @lists.eq(i).find("[data-id=#{jester.id}]").addClass("active")

  toggle: (e) =>
    li = $(e.target).closest("[data-id]")
    id = li.attr("data-id")
    show = @shows[li.closest("ul").prevAll("ul").length]
    if show.cast().role(id) is "muso"
      show.cast().remove id
      li.removeClass "active"
    else
      show.cast().set id, "muso"
      li.addClass "active"