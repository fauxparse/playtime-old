class App.Controller extends Spine.Controller
  tappable: (el, handler) ->
    if Modernizr.touch
      @el.on "touchstart", el, (e) => @tapStart e, el
    @el.on "click", el, handler if handler?

  tapStart: (e, el) =>
    target = $(e.target).parents(el).andSelf().first()
    unless tapManager = target.data("tap")
      target.data "tap", tapManager = new TapManager target
    tapManager.start e

  delegateEvents: (events) ->
    for key, method of events

      if typeof(method) is 'function'
        # Always return true from event handlers
        method = do (method) => =>
          method.apply(this, arguments)
          true
      else
        unless @[method]
          throw new Error("#{method} doesn't exist")

        method = do (method) => =>
          @[method].apply(this, arguments)
          true

      match      = key.match(@eventSplitter)
      eventName  = match[1]
      selector   = match[2]

      if selector is ''
        @el.bind(eventName, method)
      else if eventName is "tap"
        @tappable selector, method
      else
        @el.delegate(selector, eventName, method)

class TapManager
  @DRAG_THRESHOLD: 10
  @CLICK_THRESHOLD: 25
  @ghostClicks: []

  constructor: (target) ->
    @target = $(target)[0]

  start: (event) =>
    @_touched = true
    @startEvent = event.originalEvent
    @position = { x: @startEvent.touches[0].screenX, y: @startEvent.touches[0].screenY }
    event.stopPropagation()
    @target.addEventListener "touchend", @, false
    document.body.addEventListener "touchmove", @, false

  handleEvent: (event) =>
    switch event.type
      when "touchmove" then @touchMove event
      when "touchend"  then @touchend  event
      when "click"     then @click     event

  touchMove: (event) =>
    dx = Math.abs(event.touches[0].screenX - @position.x)
    dy = Math.abs(event.touches[0].screenY - @position.y)
    event.stopPropagation()
    if dx > @constructor.DRAG_THRESHOLD or dy > @constructor.DRAG_THRESHOLD
      @reset()
      $(event.target).one "click", (e) -> e.stopPropagation()
      $(@target).parent().trigger "touchstart", touches: @startEvent.touches

  touchend: (event) =>
    if @_touched
      @click event

  click: (event) =>
    event.stopPropagation()
    @reset()
    $(@target).trigger "click"

    if event.type is "touchend"
      @constructor.preventGhostClick @position.x, @position.y

  reset: ->
    @_touched = false
    @target.removeEventListener "touchend", @, false
    document.body.removeEventListener "touchmove", @, false

  @preventGhostClick: (x, y) ->
    @ghostClicks.push [x, y]
    setTimeout (=> @ghostClicks.shift()), 400

  @click: (event) =>
    for [x, y] in @ghostClicks
      # if Math.abs(event.clientX - x) < @CLICK_THRESHOLD and Math.abs(event.clientY - y) < @CLICK_THRESHOLD
      event.stopPropagation()
      event.preventDefault()

document.addEventListener "click", TapManager.click, true
