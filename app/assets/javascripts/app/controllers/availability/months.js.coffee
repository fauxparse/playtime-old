#= require ../monthly

class App.Controllers.Availability.Months extends App.Controllers.Monthly
  base: "/calendar"
  items: App.Controllers.Availability.Month

  init: ->
    @html @view("shows/months")()
    super

