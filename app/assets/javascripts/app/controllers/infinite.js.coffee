#= require ./stackable

class InfinitePage extends App.Controller
  init: ->
    @append $("<h1>").text(@index)

class App.Controllers.Infinite extends Spine.Controller
  items: InfinitePage
  
  events:
    "touchstart"            : "touchstart"
    "touchmove"             : "touchmove"
    "touchend"              : "touchend"
  
  init: ->
    @pages = {}
    @el.addClass "infinite"
    @append(@container = $("<div>", class: "pages"))

  go: (index, animate = true, force = false) =>
    if (index != @index) or force
      animate and= @el.closest(".sections").hasClass("in")
      @trigger "changing", index
      @loadPage index
      @loadPage index + 1
      @loadPage index - 1
      oldIndex = @index
      @index = index
      @activate index
      @container.animateIf animate, { x: "#{index * -100}%" }, =>
        @trigger "change", index
        @deactivate oldIndex
  
  next: (e) =>
    e?.stopPropagation()
    @go @index + 1
    false

  prev: (e) =>
    e?.stopPropagation()
    @go @index - 1
    false
    
  touchstart: (events...) =>
    event = events.pop()
    touches = event.touches or event.originalEvent.touches
    @_touch = { clientX: touches[0].clientX, clientY: touches[0].clientY }
    @_width = @container.width()
    event.stopPropagation?()
    
  touchmove: (event) =>
    if @_touch
      touches = event.originalEvent.touches
      dx = touches[0].clientX - @_touch.clientX
      dy = touches[0].clientY - @_touch.clientY
      if Math.abs(dx) > Math.abs(dy)
        @_px = dx * 100 / @_width
        event.preventDefault()
      else
        @_px = 0
      @container.transition({ x: "#{@index * -100 + @_px}%" }, 0)
      event.stopPropagation()

  touchend: (event) =>
    if @_touch
      if @_px < -30
        @next()
      else if @_px > 30
        @prev()
      else if @_px
        @go @index, true, true
      @_px = 0
      delete @_touch
    event.stopPropagation()
    
  loadPage: (index) =>
    key = "p#{index}"
    if !@pages[key]
      (@pages[key] = new @items({ index: index }))
        .appendTo(@container)
        .addClass("page")
        .css("left", "#{index * 100}%")

  activate: (index) ->
    @pages["p#{index}"]?.el.trigger "activate"

  deactivate: (index) ->
    @pages["p#{index}"]?.el.trigger "deactivate"
