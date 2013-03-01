class App.Controllers.Shows.Notes extends App.Controllers.Stackable
  elements:
    ".comments" : "notes"
    "form" : "form"

  events:
    "submit form" : "create"
    "tap .comments [rel=delete]" : "deleteNote"

  init: ->
    @el.addClass "notes"
    super
    @html @view("shows/notes")(show: @show)
    @refresh()

  refresh: (show) ->
    show ?= @show
    @notes.empty()
    for note in @show.notes()
      @notes.append @view("shows/note")(note: note)

  create: (e) ->
    e.preventDefault()
    note = App.Models.Note.fromForm @form
    unless note.empty()
      note.time new Date()
      el = $(@view("shows/note")(note: note)).appendTo(@notes)
      note.bind "changeID", (note, _, id) -> el.attr "data-id", id
      note.save ajax: { url: @show.notesURL() }
      @show.notes().push note
      @show.trigger "update", from: "notes"
      @form[0].reset()

  deleteNote: (e) ->
    el = $(e.target).closest("li").fadeOut -> $(@).remove()
    id = el.attr("data-id")
    note = @show.notes().remove id
    note.destroy ajax: { url: @show.notesURL() + "/" + id }
    @show.trigger "update", from: "notes" 