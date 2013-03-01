#= require ./jester
#= require ./cast
#= require ./note

Jester = App.Models.Jester
Cast = App.Models.Cast
Note = App.Models.Note

class App.Models.Show extends Spine.Model
  @configure "Show", "notes"
  @_months: {}
  @_fetching: {}
  @_timestamps: {}
  
  @TIMEOUT: 30 * 60 * 60 * 1000
  @BATCH_TIMEOUT: 2000

  date: ->
    @_date ?= Date.fromDB(@id) if @id?
    @_date
    
  url: ->
    "/shows/#{@date().format("%Y/%m/%d")}"
    
  cast: (cast) ->
    if cast? or !@_cast?
      @_cast = new Cast(cast or {}) 
      @_cast.bind "change", @castChanged
    @_cast
    
  notes: (notes) ->
    @_notes ?= new Notes(notes)
    @_notes.assign notes if notes?
    @_notes

  notesURL: ->
    @url() + "/notes"

  friday: ->
    @date().plus(5 - @date().getDay())

  saturday: ->
    @date().plus(6 - @date().getDay())
    
  castChanged: (id, role) =>
    @trigger "cast", id, role
    
  toJSON: ->
    $.extend @attributes, cast: @cast().toJSON()
  
  @month: (year, month, force = false) ->
    key = "#{year}-#{month}"
    promise = $.Deferred()
    return @_fetching[key] if @_fetching[key]
    if @fresh(key) and !force
      promise.resolve @_months[key]
    else
      @_fetching[key] = promise
      $.getJSON("/shows/#{year}/#{month}")
        .done (data) =>
          @one "refresh", (shows) =>
            @_months[key] = shows
            @_timestamps[key] = new Date().getTime()
            promise.resolve shows
          @refresh data
        .fail ->
          promise.reject()
        .always =>
          delete @_fetching[key]
    promise
    
  @day: (year, month, day, force = false) ->
    promise = $.Deferred()
    @month(year, month, force)
      .done (shows) ->
        for show in shows
          if show.date().getDate().toString() == day.toString()
            promise.resolve(show)
            break
      .fail ->
        promise.reject()
    promise
    
  @fresh: (key) ->
    @_months[key] and
    @_timestamps[key] + @TIMEOUT > new Date().getTime()
    
  @castChanged: (show, id, role) =>
    @_changes ?= {}
    @_changes[show.id] ?= {}
    @_changes[show.id][id] = role
    @scheduleBatch()
    
  @scheduleBatch: ->
    clearTimeout(@_batchTimer) if @_batchTimer
    @_batchTimer = setTimeout @saveBatch, @BATCH_TIMEOUT
    
  @saveBatch: =>
    @_batchTimer = false
    $.ajax
      url: "/shows"
      type: "put"
      dataType: "json"
      data: { changes: @_changes }
    .done (data) =>
      @_changes = {} unless @_batchTimer
    
  @bind "cast", @castChanged
  
class Notes extends Array
  constructor: (notes = []) ->
    @assign notes

  assign: (notes = []) ->
    @splice 0, @length, (new Note(note.attributes?() or note) for note in notes or [])...

  remove: (note) ->
    id = note.id ? note
    for note, i in @
      if note.id is id
        return @splice(i, 1)[0]
