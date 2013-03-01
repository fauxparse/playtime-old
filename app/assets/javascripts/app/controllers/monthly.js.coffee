#= require ./stackable
#= require ./infinite

class App.Controllers.Monthly extends App.Controllers.Stackable
  base: ""

  init: ->
    @el.addClass "monthly"
    @months = new App.Controllers.Infinite el: @$(".months"), items: @items
    @months.bind "change", @change
    @route "#{@base}", @home
    @route "#{@base}/:year/:month", (params) =>
      @months.go @constructor.toIndex(params.year, params.month), false
    @tappable "[rel=prev]", @months.prev
    @tappable "[rel=next]", @months.next
    super
  
  go: (params...) => @months.go params...

  home: =>
    [ year, month ] = @constructor.fromIndex 0
    @navigate "#{@base}/#{year}/#{month}", true
  
  change: (index) =>
    [ year, month ] = @constructor.fromIndex index
    @navigate "#{@base}/#{year}/#{month}", false
  
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
