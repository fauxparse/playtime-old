class App.Controllers.Shows.Month extends App.Controller
  elements:
    ".shows-this-month" : "list"

  events:
    "tap .shows-this-month>li" : "go"

  init: ->
    [ @year, @month ] = App.Controllers.Shows.Months.fromIndex @index
    @el.addClass("month")
      .attr("data-year", @year)
      .attr("data-month", @month)
    @append $("<ul>", class: "shows-this-month")
    App.Models.Show.month(@year, @month).done @populate
    @bind "release", @unbindShows
  
  unbindShows: =>
    for show in @shows
      show.unbind "update", @refreshShow

  populate: (shows) =>
    @list.empty()
    @shows = shows.slice 0
    for show in @shows
      show.bind "update", @refreshShow
      @list.append @render(show)
    
  render: (show) =>
    $ @view("shows/summary")(show: show)
  
  refreshShow: (show) =>
    @$("[data-date=#{show.id}]").replaceWith @render(show)

  go: (e) =>
    @navigate $(e.target).closest("[data-path]").attr("data-path"), true