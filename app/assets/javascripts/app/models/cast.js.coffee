#= require ./jester

Jester = App.Models.Jester

class App.Models.Cast extends Spine.Module
  @include Spine.Events
  @ROLES = [ "mc", "player", "guest", "muso", "notes", "available" ]
  
  constructor: (cast) ->
    @cast = $.extend {}, cast or {}
  
  role: (id) ->
    @cast[id.id or id]
    
  availability: (id) ->
    switch @role(id)
      when undefined then undefined
      when "unavailable" then false
      else true
        
  available: (id) ->
    @set id, "available" unless @availability id
  
  set: (id, role) ->
    if role is "unknown"
      @remove id
    else
      id = id.id if id.id?
      @cast[id] = role
      @trigger "change", id, role
    
  remove: (id) ->
    id = id.id if id.id?
    delete @cast[id]
    @trigger "change", id, null
  
  sorted: ->
    sorted = []
    for role in @constructor.ROLES when role isnt "available"
      sorted.push [ role, (Jester.exists(id) or id for own id, r of @cast when r is role) ]
    sorted
    
  any: ->
    for own key, value of @cast
      return true unless value in [ "available", "unavailable" ]
    false
    
  each: (callback) ->
    for own id, role of @cast
      callback(Jester.exists(id) or id, role)
    @
  
  guest: (name) ->
    @set name.replace(/[\.\$]/g, ""), "guest"
  
  guests: -> (id for own id, role of @cast when role is "guest")
  
  toJSON: -> $.extend {}, @cast
    
  @comparator: (a, b) =>
    ar = @ROLES.indexOf(a[1])
    br = @ROLES.indexOf(b[1])
    if (ar == br) then a[0].compare b[0] else ar - br
    
