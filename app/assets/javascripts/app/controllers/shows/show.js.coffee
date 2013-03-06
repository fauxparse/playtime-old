class App.Controllers.Shows.Show extends App.Controller
  elements:
    ".cast" : "cast"
    "header [rel=notes] span" : "notesCounter"

  events:
    "tap .cast li" : "toggle"
    "tap header [rel=view]" : "changeView"
    "tap header [rel=guest]" : "addSpecialGuest"
    "tap header [rel=notes]" : "showNotes"
    "tap footer [rel=cancel]" : "deselect"
    "tap footer [rel=with]" : "changeRole"

  FRESH: [51, 51, 51]
  STALE: [255, 113, 81]
  STALE_PERIOD: 5 * 7 * 24 * 60 * 60 * 1000 # completely stale after 5 weeks

  init: ->
    @el.addClass "show loading"
    @date = App.Controllers.Shows.Days.fromIndex @index
    [@year, @month, @day] = [@date.getFullYear(), @date.getMonth() + 1, @date.getDate()]
    App.Models.Show.day(@year, @month, @day).done @render
    @bind "release", @unbindShow

  render: (show) =>
    if show? and show instanceof App.Models.Show
      @unbindShow @show if @show?
      @show = show
      @show.bind "update", @refresh
    @html @view("shows/show")(show: @show)
    @refresh()

  refresh: (show, options = {}) =>
    unless options?.from is "show"
      show ?= @show
      @cast.empty()
      for guest in show.cast().guests()
        @cast.append @renderGuest(guest)
      for jester in App.Models.Jester.sorted()
        @cast.append @renderJester(jester)
      @$(".cast li").removeAttr("data-role")
      show.cast().each (jester, role) =>
        @$("[data-id=#{jester.id ? jester.slugify()}]").attr "data-role", role or "unavailable"
    @notesCounter.text(@show.notes().length or "")
    @el.removeClass "loading"
    @changeView @el.attr("data-view") or (if show.cast().any() then "cast" else "available"), true

  unbindShow: =>
    @show?.unbind "update", @refresh

  renderGuest: (guest) =>
    console.log guest
    @person(guest)
      .attr("data-id": guest.slugify(), "data-role": "guest")

  renderJester: (jester) =>
    p = @person(jester.toString())
      .attr("data-id": jester.id)
      .toggleClass("active", jester.active)
    if jester.active and @show.last[jester.id]?
      p.css(color: @fadeByDate(@show.date(), Date.fromDB(@show.last[jester.id])))
    p

  fadeByDate: (now, last) ->
    d = Math.min now.getTime() - last.getTime(), @STALE_PERIOD
    p = Math.sqrt(d * 1.0 / @STALE_PERIOD)
    rgb = ((c * p + @FRESH[i] * (1.0 - p)).toFixed() for c, i in @STALE)
    "rgb(#{rgb.join ","})"

  person: (name) =>
    $("<li>").append($("<span>").append("<i class=\"icon\"></i> ").append($("<b>").text(name)))

  toggle: (e) ->
    $(e.target).closest("li").toggleClass "selected"
    @toggleSelection()

  toggleSelection: ->
    @el.toggleClass "has-selection", !!$(".selected", @cast).length

  deselect: ->
    $(".selected", @cast).removeClass "selected"
    @toggleSelection()

  changeView: (view, force = false) ->
    oldView = @el.attr "data-view"
    view = $(view.target).closest("[data-view]").attr("data-view") if view.target?
    @$("[rel=view][data-view=#{view}]").addClass("active")
      .siblings("[rel=view]").removeClass("active")
    @el.attr("data-view", view).removeClass("has-selection")
    @$("li.selected").removeClass "selected"
    if view is "cast" and (force or oldView isnt "cast")
      for role in App.Models.Cast.ROLES
        @$(".cast li[data-role=#{role}]").appendTo @cast
    else if view isnt "cast" and (force or oldView is "cast")
      for jester in App.Models.Jester.sorted()
        @$(".cast li[data-id=#{jester.id}]").appendTo @cast

  changeRole: (e) ->
    role = $(e.target).closest("[data-role]").attr("data-role")
    unless role is "cancel"
      @$(".selected").each (i, el) =>
        $li = $(el)
        id = $li.attr("data-id")
        unless jester = App.Models.Jester.exists(id)
          id = $("b", el).text()
          if role in [ "unavailable", "unknown" ]
            role = "unknown"
          else
            role = "guest"
        if role is "unknown"
          $li.removeAttr "data-role"
          @show.cast().remove id
          $li.remove() unless jester
        else
          @show.cast().set id, role
          $li.attr "data-role", role
    @show.save from: "show"
    @deselect()

  showNotes: (e) ->
    @navigate @show.date().format("/shows/%Y/%o/%d/notes"), true

  addSpecialGuest: (e) ->
    modal = new App.Controllers.Shows.SpecialGuest
    modal.appendTo(@el)
    modal.bind "ok", =>
      name = modal.name.val().trim()
      @cast.prepend @renderGuest(name)
      @changeView "cast", true
      @show.cast().guest(name)
      @show.save from: "show"
    modal.show()
