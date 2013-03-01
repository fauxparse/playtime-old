#= require ../stackable
#= require ../infinite

class App.Controllers.Shows.Days extends App.Controllers.Stackable
  elements:
    ">header" : "header"
    ">header>h2" : "title"

  init: ->
    @el.addClass "days"
    @html @view("shows/days")()
    @days = new App.Controllers.Infinite el: @$(".days"), items: App.Controllers.Shows.Show
    @days.bind "change", @change
    @days.bind "changing", @changing
    @tappable "[rel=prev]", @days.prev
    @tappable "[rel=next]", @days.next
    super

  go: (params...) => @days.go params...

  change: (index) =>
    date = @constructor.fromIndex index
    @navigate "/shows/#{date.format("%Y/%o/%d")}", false

  changing: (index) =>
    date = @constructor.fromIndex(index)
    @path = "/shows/#{date.format("%Y/%o/%d")}"
    date = date.format("%d %b %Y")
    unless index is @index
      if @index?
        d = Math.sgn(@index - index)
        @title.transition { left: 100 * d + "%", opacity: 0 }, -> $(@).remove()
        @title = $("<h2>").text(date).appendTo(@header)
          .css({ left: -100 * d + "%", opacity: 0 })
          .transition({ left: 0, opacity: 1 })
      else
        @title.text date
      @index = index

  @current: ->
    unless @_current
      d = d.nextFriday() unless (d = new Date).isSaturday()
      @_current = new Date d.getFullYear(), d.getMonth(), d.getDate(), 5
    @_current
    
  @next: ->
    unless @_next
      d = new Date().nextFriday()
      @_next = new Date d.getFullYear(), d.getMonth(), d.getDate(), 5
    @_next
  
  @toIndex: (year, month, day) ->
    date = new Date parseInt(year, 10), parseInt(month, 10) - 1, parseInt(day, 10), 5
    d = Math.floor((date.getTime() - @next().getTime()) / Date.DAY)
    Math.trunc(d / 7.0) * 2 + Math.ceil((d % 7) / 6)
  
  @fromIndex: (index) ->
    d = Math.trunc(index / 2) * 7 + (index % 2) * (if index < 0 then 6 else 1)
    @next().plus(d)

