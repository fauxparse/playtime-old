#= require_tree ./lib
#= require_self
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views

class App extends Spine.Controller
  @Controllers:
    Shows:        {}
    Availability: {}
    Jesters:      {}
    Musos:        {}
    Awards:       {}
  @Models: {}
  
  LOCATION_KEY: "saved_location"
  
  init: ->
    window.location.hash = @savedLocation() if navigator.standalone
    $(window).on "hashchange", @saveLocation
    App.Controllers.Login.login().done @start
    
  start: =>
    @routes
      "/" : @home
      "/logout" : @logout
    @application = new App.Controllers.Application el: ".application"
    @home() unless window.location.hash > "#/"

  home: =>
    @navigate "/shows", true

  logout: =>
    App.Controllers.Login.logout().done =>
      Spine.Route.unbind()
      Spine.Route.routes = []
      @application.release()
      $("<div>", class: "application").appendTo("body")
      @navigate "/", false
      App.Controllers.Login.login().done @start
      
  saveLocation: =>
    if window.localStorage?
      localStorage.setItem @LOCATION_KEY, location.hash.replace(/^#/, "")
      
  savedLocation: ->
    if window.localStorage?
      localStorage.getItem @LOCATION_KEY
    

window.App = App
$ ->
  window.app = new App el: "body"
