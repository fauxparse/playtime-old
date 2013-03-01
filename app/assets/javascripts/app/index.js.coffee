#= require_tree ./lib
#= require_self
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views

class App extends Spine.Controller
  @Controllers:
    Shows: {}
    Availability: {}
  @Models: {}
  
  init: ->
    @routes
      "/" : @home
    App.Controllers.Login.login().done @start
    
  start: =>
    @application = new App.Controllers.Application el: ".application"
    @home() unless window.location.hash > "#"

  home: =>

window.App = App
$ ->
  window.app = new App el: ".application"
