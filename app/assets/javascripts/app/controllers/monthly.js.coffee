#= require ./stackable
#= require ./infinite

class App.Controllers.Monthly extends App.Controllers.Stackable
  base: ""

  init: ->
    @el.addClass "monthly"
    @header = @$("header")
    @title = @$("header h2")
    @months = new App.Controllers.Infinite el: @$(".months"), items: @items
    @months.bind "change", @change
    @months.bind "changing", @changing
    @route "#{@base}", @home
    @route "#{@base}/:year/:month", (params) =>
      @months.go @constructor.toIndex(params.year, params.month), false
    @tappable "[rel=prev]", @months.prev
    @tappable "[rel=next]", @months.next
    super
  
  go: (params...) => @months.go params...

  home: =>
    if @path > "/"
      @navigate @path, false
    else
      @go 0, false, true
  
  change: (index) =>
    [ year, month ] = @constructor.fromIndex index
    @navigate "#{@base}/#{year}/#{month}", false

  changing: (index) =>
    [ year, month ] = @constructor.fromIndex index
    date = new Date(year, month - 1, 1).format("%B %Y")
    unless index is @index
      @path = "#{@base}/#{year}/#{month}"
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
      d = new Date
      @_current = d.getFullYear() * 12 + d.getMonth()
    @_current
  
  @fromIndex: (index) ->
    dm = @current() + index
    [ Math.floor(dm / 12), dm % 12 + 1 ]
    
  @toIndex: (year, month) ->
    parseInt(year, 10) * 12 + parseInt(month, 10) - 1 - @current()
