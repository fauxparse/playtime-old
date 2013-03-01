class App.Controllers.Stack extends Spine.Controller
  tag: "section"

  elements:
    ".stack" : "stack"

  events:
    "up .stackable:gt(0)" : "pop"

  controllers: []

  sections:
    shows: App.Controllers.Shows.Shows

  init: ->
    @append $("<div class=\"stack\">")
    @push @first if @first?

  push: (controller) ->
    @controllers[0].path ?= Spine.Route.path if @controllers.length
    controller = new controller unless controller instanceof Spine.Controller
    controller.stack = @
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
      @pop() while @controllers.length > i + 1

  find: (controller) =>
    for c in @controllers
      return c if c instanceof controller
    null