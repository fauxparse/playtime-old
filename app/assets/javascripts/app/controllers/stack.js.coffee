class App.Controllers.Stack extends App.Controller
  tag: "section"

  elements:
    ".stack" : "stack"

  events:
    "up .stackable:gt(0)" : "pop"

  sections:
    shows: App.Controllers.Shows.Shows

  init: ->
    @controllers = []
    @append $("<div class=\"stack\">")
    @push @first if @first?

  push: (controller) ->
    controller = new controller unless controller instanceof Spine.Controller
    controller.stack = @
    controller.path ?= Spine.Route.path
    @controllers.unshift controller
    controller.el
      .addClass("stackable screen")
      .appendTo(@stack)
    @immediately -> controller.el.addClass("in")
    controller

  pop: (e) =>
    controller = @controllers.shift()
    @immediately -> controller.el.removeClass("in")
    @after 300, => controller.release()
    if @controllers.length
      @navigate @controllers[0].path, false

  popUntil: (controller) =>
    @pop() while @controllers.length and !(@controllers[0] instanceof controller)

  popAfter: (controller) =>
    if i = @controllers.indexOf(controller)
      @pop() while i-- > 0

  find: (controller) =>
    for c in @controllers
      return c if c instanceof controller
    null