#= require ../stack

class App.Controllers.Shows.Shows extends App.Controllers.Stack
  tag: "section"

  init: ->
    super
    @push App.Controllers.Shows.Months
    @route "/shows/:year/:month/:day/notes", @notes
    @route "/shows/:year/:month/:day", @show

  show: (params) =>
    @goToDay params.year, params.month, params.day

  notes: (params) =>
    @goToDay params.year, params.month, params.day, false
    @navigate "/shows/#{params.year}/#{params.month}/#{params.day}/notes", false
    $.when(App.Models.Show.day(params.year, params.month, params.day)).done (show) =>
      @push new App.Controllers.Shows.Notes(show: show)

  goToMonth: (year, month, pop = true) ->
    months = @find(App.Controllers.Shows.Months) or @push(App.Controllers.Shows.Months)
    @popAfter months if pop
    months.go App.Controllers.Monthly.toIndex(year, month), false
    months

  goToDay: (year, month, day, pop = true) ->
    @goToMonth year, month, false
    days = @find(App.Controllers.Shows.Days) or @push(App.Controllers.Shows.Days)
    @popAfter days if pop
    days.go App.Controllers.Shows.Days.toIndex(year, month, day), false
    days
  