class App.Controllers.Modal extends App.Controller
  init: ->
    @el.addClass "modal"
    @tappable "[data-action]", @perform

  appendTo: ->
    super
    @overlay = $("<div>", "class": "modal-overlay").insertBefore(@el).fadeIn()
    @el

  perform: (e) =>
    button = $(e.target).closest "[data-action]"
    @trigger button.attr "data-action"
    @hide()

  show: =>
    @immediately => @el.addClass "in"

  hide: =>
    @immediately => @el.removeClass "in"
    @overlay?.fadeOut -> $(@).remove()
    @after 350, @release
