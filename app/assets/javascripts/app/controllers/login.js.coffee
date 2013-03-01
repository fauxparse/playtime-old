class App.Controllers.Login extends App.Controller
  @URL: "/login"

  elements:
    "form" : "form"
    "[name=email]" : "email"
    "button" : "button"
    ".message" : "message"
    ".overlay" : "overlay"

  events:
    "submit form" : "login"

  init: ->
    @el
      .addClass("login")
      .appendTo(".application")
    @html @view("login/form")()
    @tappable "button", => @form.submit()

  show: =>
    @immediately => @el.addClass "in"

  hide: =>
    @el.removeClass "in"

  login: (event) =>
    if event?
      event.preventDefault()
      event.stopPropagation()
    @button.focus()
    @message.empty()
    @overlay.fadeIn()
    $.ajax
      url:      @constructor.URL
      type:     "post"
      dataType: "json"
      data:     @form.serialize()
    .done(@success)
    .error(@error)

  success: (data, textStatus, jqXHR) =>
    @overlay.fadeOut()
    @message.empty()
    @constructor.setup data, @promise
    @hide()
    @promise.resolve()
    
  error: (jqXHR, textStatus, errorThrown) =>
    @overlay.fadeOut()
    @message.html "Sorry, I can’t let you log in like that."
    @email.focus()

  @login: ->
    login = $.Deferred()
    $.getJSON(@URL)
      .done((data) => @setup data, login)
      .error(=> @show login)
    login

  @logout: ->
    $.ajax
      url: "/logout"
      type: "delete"

  @setup: (data, promise) ->
    App.Models.Jester.refresh data.jesters
    App.Models.Jester.current data.current
    promise.resolve()
    
  @show: (login) ->
    new @(promise: login).show()
