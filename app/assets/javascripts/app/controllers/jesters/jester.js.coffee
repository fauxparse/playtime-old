#= require ../stackable

class App.Controllers.Jesters.Jester extends App.Controllers.Stackable
  init: ->
    @path = "/jesters/#{@jester.slug}"
    super
    @el.addClass "jester loading"
    @loadStats().done @refresh

  loadStats: =>
    $.ajax
      url: "/jesters/#{@jester.slug}/stats"
      type: "get"
      dataType: "json"

  refresh: (data) =>
    @el.removeClass "loading"
    thisYear = new Date().getFullYear()
    [players, casts] = for list in ["played_with", "mced_with"]
      ids = ([id, count] for own id, count of data.all[list])
      ids.sort (a, b) ->
        b[1] - a[1]
      (App.Models.Jester.exists(id) for [id, count] in ids.slice(0, 5))

    @html @view("jesters/jester")
      jester: @jester
      thisYear: thisYear
      lastYear: thisYear - 1
      stats: data
      players: players
      casts: casts
