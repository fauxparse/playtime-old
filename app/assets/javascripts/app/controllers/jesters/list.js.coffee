#= require ../stackable

class App.Controllers.Jesters.List extends App.Controllers.Stackable
  elements:
    ".list" : "list"
    ".jesters header" : "menu"

  events:
    "tap .list li" : "zoom"
    "tap header [rel=new]" : "newJester"
    "tap header .active a" : "toggleMenu"
    "tap header .years li:not(.active) a" : "changeYear"
    "tap header .stats li:not(.active) a" : "changeStatistic"

  path: "/jesters"

  stats: {}
  loading: {}

  init: ->
    super
    @html @view("jesters/list")()
    @setStatistic "name"
    @setYear new Date().getFullYear()
    @render()
    App.Models.Jester.bind "update create destroy", @changed

  render: =>
    @list.empty()
    for jester in App.Models.Jester.sorted()
      $(@view("jesters/row")(jester: jester))
        .toggleClass("active", jester.active)
        .appendTo(@list)

  changed: (jester) =>
    @render()

  zoom: (e) =>
    slug = $(e.target).closest("[data-slug]").attr("data-slug")
    @navigate "/jesters/#{slug}", true

  toggleMenu: (e) =>
    e.stopPropagation()
    e.preventDefault()
    @menu.toggleClass "open"

  changeYear: (e) =>
    e.stopPropagation()
    e.preventDefault()
    @setYear $(e.target).closest("[data-year]").attr("data-year")
    @menu.removeClass "open"

  changeStatistic: (e) =>
    e.stopPropagation()
    e.preventDefault()
    @setStatistic $(e.target).closest("[data-stat]").attr("data-stat")
    @menu.removeClass "open"

  setYear: (year) =>
    @year = year
    @$("header [data-year=#{@year}]").closest("li").addClass("active").siblings().removeClass("active")
    if @stats[year]
      @refresh()
    else
      unless @loading[year]
        @loading[year] = true
        @el.addClass "loading"
        $.ajax
          url: "/jesters/stats"
          type: "get"
          dataType: "json"
          data: { year: year }
        .done (data) =>
          @stats[year] = data
          @refresh()
          @el.removeClass "loading"
          delete @loading[year]

  refresh: =>
    @$(".list li").hide()
    ids = []
    for own id, stats of @stats[@year]
      jester = App.Models.Jester.find id
      if @stat is "name" or (stat = stats[@stat] and jester._type isnt "Muso")
        ids.push id
        stat = switch @stat
          when "name" then ""
          when "last_played", "last_mced" then Date.fromDB(stats[@stat]).format("%d %b")
          when "ratio" then stats[@stat].percentage()
          else stats[@stat]
        @$(".list [data-id=#{id}]").show().find(".stat").html stat
    if @stat is "name" and @year is "all"
      @$(".list li").not(":visible").each (i, el) ->
        ids.push $(el).show().attr("data-id")
    @sort ids
    @immediately =>
      @$(".list li:visible").each (i, el) =>
        $(el).css
          top: (ids.indexOf($(el).attr("data-id")) - i) * 49

  sort: (ids) ->
    if @stat is "name"
      ids.sort (a, b) ->
        [a, b] = (App.Models.Jester.exists(id).toString() for id in [a, b])
        a.localeCompare b
    else if @stat is "ratio" or @stat is "player"
      ids.sort (a, b) => (@stats[@year][b][@stat] or -Math.Infinity) - (@stats[@year][a][@stat] or -Math.Infinity)
    else
      ids.sort (a, b) => (@stats[@year][b][@stat] or "Z").localeCompare (@stats[@year][a][@stat] or "Z")
    ids


  setStatistic: (stat) =>
    @stat = stat
    @$("header [data-stat=#{@stat}]").closest("li").addClass("active").siblings().removeClass("active")
    @refresh() if @year

  newJester: =>
    @navigate "/jesters/new", true