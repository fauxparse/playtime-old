#= require ../modal

class App.Controllers.Shows.SpecialGuest extends App.Controllers.Modal
  elements:
    "form" : "form"
    "[name=name]" : "name"

  events:
    "submit form" : "submit"

  init: ->
    @html @view("shows/special_guest")()
    super

  show: ->
    super

  submit: (e) =>
    e.preventDefault()
