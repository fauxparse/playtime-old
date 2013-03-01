class App.Controllers.Availability.Month extends App.Controller
  @STATES: [ "unknown", "available", "unavailable" ]
  
  events:
    "mousedown  [data-day=friday], [data-day=saturday]" : "startPainting"
    "mousemove  [data-day=friday], [data-day=saturday]" : "keepPainting"
    "touchstart [data-day=friday], [data-day=saturday]" : "touch"
    "touchmove  [data-day=friday], [data-day=saturday]" : "touchMove"

  init: ->
    [ @year, @month ] = App.Controllers.Availability.Months.fromIndex @index
    @el.addClass("month")
      .attr("data-year", @year)
      .attr("data-month", @month)
    @render()
    @bind "release", @unbindShows

  render: ->
    @calendar = $("<ul>", class: "calendar").appendTo(@el)
    for d in Date.weekdays
      @calendar.append $("<li>", class: "header", "data-day": d.toLowerCase(), "text": d.substring(0,1))
    date = new Date @year, @month - 1, 1, 5
    d = date
    while d.getMonth() is date.getMonth()
      day = $ "<li>",
        "data-day": Date.weekdays[d.getDay()].toLowerCase()
        "data-date": d.format()
        "text": d.getDate()
      day.appendTo @calendar
      d = new Date d.getTime() + Date.DAY
    $("li", @calendar).eq(7).addClass("offset-#{date.getDay()}")
    @refresh()
  
  unbindShows: =>
    for show in @shows
      show.unbind "update", @refreshShow

  populate: (shows) =>
    @shows = shows.slice 0
    @$("li").attr "data-state", "unknown"
    me = App.Models.Jester.current().id
    for show in @shows
      show.bind "update", @refresh
      if (available = show.cast().availability(me)) isnt undefined
        @$("[data-date=#{show.id}]").attr "data-state", ["unavailable", "available"][+available]

  refresh: (show, options = {}) =>
    unless options?.from is "calendar"
      clearTimeout @_refreshTimer if @_refreshTimer?
      @immediately @delayedRefresh
    
  delayedRefresh: =>
    delete @_refreshTimer
    @unbindShows() if @shows
    App.Models.Show.month(@year, @month).done @populate

  startPainting: (e) ->
    el = $(e.target).closest("li")
    i = @constructor.STATES.indexOf el.attr("data-state")
    @state = @constructor.STATES[(i + 1) % @constructor.STATES.length]
    @paint el, @state
        
  paint: (target, state) ->
    unless target.attr("data-state") is state
      if target.data("day") in [ "friday", "saturday" ]
        target.attr "data-state", state
        show = App.Models.Show.find(target.data("date"))
        show.cast().set App.Models.Jester.current(), state
        show.save from: "calendar"

  keepPainting: (e) ->
    if e.which
      e.preventDefault()
      e.stopPropagation()
      @paint $(e.target).closest("li"), @state

  touch: (e) ->
    e.preventDefault()
    e.stopPropagation()
    touches = event.touches or event.originalEvent.touches
    if touches.length
      @startPainting target: e.target
      
  touchMove: (e) ->
    e.preventDefault()
    e.stopPropagation()
    touches = event.touches or event.originalEvent.touches
    @paint $(document.elementFromPoint(touches[0].clientX, touches[0].clientY)).closest("li"), @state


