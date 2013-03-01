#= require ../stackable

class App.Controllers.Availability.Weekends extends App.Controllers.Stackable
  elements:
    "header" : "header"
    "header h2" : "title"

  init: ->
    @el.addClass "weekends"
    @html @view("availability/weekends")()
    @weekends = new App.Controllers.Infinite el: @$(".weekends"), items: App.Controllers.Availability.Weekend
    @weekends.bind "change", @change
    @weekends.bind "changing", @changing
    @route "/availability", @home
    @route "/availability/:year/:month/:day", (params) =>
      @go @constructor.toIndex(params.year, params.month, params.day), false
    @tappable "[rel=prev]", @weekends.prev
    @tappable "[rel=next]", @weekends.next
    super

  go: (params...) => @weekends.go params...

  home: =>
    if @path
      @navigate @path, false
    else
      @go 0, false, true
  
  changing: (index) =>
    friday = @constructor.fromIndex index
    saturday = new Date(friday.getTime() + Date.DAY)
    date = Date.range(friday, saturday)
    unless index is @index
      @path = "/availability/#{friday.format("%Y/%o/%d")}"
      if @index?
        d = Math.sgn(@index - index)
        @title.transition { left: 100 * d + "%", opacity: 0 }, -> $(@).remove()
        @title = $("<h2>").text(date).appendTo(@header)
          .css({ left: -100 * d + "%", opacity: 0 })
          .transition({ left: 0, opacity: 1 })
      else
        @title.text date
      @index = index

  change: (index) =>
    friday = @constructor.fromIndex index
    saturday = new Date(friday.getTime() + Date.DAY)
    @navigate "/availability/#{friday.format("%Y/%o/%d")}", false

  @fromIndex: (index) ->
    new Date(@current().getTime() + index * 7 * Date.DAY)
    
  @toIndex: (year, month, day) ->
    date = new Date parseInt(year, 10), parseInt(month, 10) - 1, parseInt(day, 10), 5
    d = new Date(date.getTime() + (date.getDay() - 5) * Date.DAY)
    Math.trunc((d.getTime() - @current().getTime()) / (Date.DAY * 7))
    
  @current: ->
    d = new Date()
    d = new Date(d.getTime() + (12 - d.getDay()) * Date.DAY)
    new Date(d.getFullYear(), d.getMonth(), d.getDate(), 5)