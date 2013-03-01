#= require ../monthly

class App.Controllers.Shows.Months extends App.Controllers.Monthly
  base: "/shows"
  items: App.Controllers.Shows.Month

  init: ->
    @html @view("shows/months")()
    super
