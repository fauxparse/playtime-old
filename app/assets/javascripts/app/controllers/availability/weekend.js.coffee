class App.Controllers.Availability.Weekend extends App.Controller
  elements:
    ".cast" : "cast"

  events:
    "tap .cast li" : "cycle"
    "tap header [rel=view]" : "changeView"

  @STATES: [ "neither", "friday", "saturday", "both" ]
  @CYCLE:  [ "unknown", "both", "friday", "saturday", "neither" ]

  init: ->
    @friday   = App.Controllers.Availability.Weekends.fromIndex @index
    @saturday = new Date(@friday.getTime() + Date.DAY)
    @el.addClass("weekend")
    @html @view("availability/weekend")(friday: @friday, saturday: @saturday)
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
    unless options.from is "availability"
      @refresh()

  refresh: =>
    @cast.empty()
    for jester in App.Models.Jester.sorted()
      li = $("<li>", "data-id": jester.id, text: jester.toString(), "data-state": "unknown")
        .toggleClass("active", jester.active)
        .appendTo(@cast)
    states = {}
    for show, i in @shows
      show.cast().each (jester, role) ->
        unless role is "guest"
          state = if role is "unavailable" then 0 else 1
          states[jester.id] = (states[jester.id] ? 0) | (state * (i + 1))
    for own id, state of states
      @$("[data-id=#{id}]").attr("data-state", @constructor.STATES[state])

  cycle: (e) =>
    $li = $(e.target).closest("li")
    state = $li.attr("data-state") || "unknown"
    newState = @constructor.CYCLE[(@constructor.CYCLE.indexOf(state) + 1) % @constructor.CYCLE.length]
    $li.attr "data-state", newState
    id = $li.data("id")
    switch newState
      when "unknown"
        show.cast().remove(id) for show in @shows
      when "both"
        show.cast().available(id) for show in @shows
      when "friday"
        @shows[0].cast().available(id)
        @shows[1].cast().set(id, "unavailable")
      when "saturday"
        @shows[0].cast().set(id, "unavailable")
        @shows[1].cast().available(id)
      when "neither"
        show.cast().set(id, "unavailable") for show in @shows
    show.save(from: "availability") for show in @shows

  changeView: (view, force = false) ->
    view = $(view.target).closest("[data-view]").attr("data-view") if view.target?
    @$("[rel=view][data-view=#{view}]").addClass("active")
      .siblings("[rel=view]").removeClass("active")
    @el.attr("data-view", view)
