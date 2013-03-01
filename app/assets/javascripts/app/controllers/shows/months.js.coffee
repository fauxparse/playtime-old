#= require ../monthly

class App.Controllers.Shows.Months extends App.Controllers.Monthly
  base: "/shows"
  items: App.Controllers.Shows.Month

  elements:
    "header" : "header"
    "header h2" : "title"

  init: ->
    @html @view("shows/months")()
    super
    @months.bind "changing", @changing

  changing: (index) =>
    [ year, month ] = @constructor.fromIndex index
    date = new Date(year, month - 1, 1).format("%B %Y")
    unless index is @index
      @path = "/shows/#{year}/#{month}"
      if @index?
        d = Math.sgn(@index - index)
        @title.transition { left: 100 * d + "%", opacity: 0 }, -> $(@).remove()
        @title = $("<h2>").text(date).appendTo(@header)
          .css({ left: -100 * d + "%", opacity: 0 })
          .transition({ left: 0, opacity: 1 })
      else
        @title.text date
      @index = index
