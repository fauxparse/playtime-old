class App.Models.Jester extends Spine.Model
  @configure "Jester", "name", "email", "active"
  @extend Spine.Model.Ajax
  
  toString: -> @name
  
  image: -> "/assets/jesters/#{@slug}.jpg"
  
  compare: (b) -> @toString().localeCompare b.toString()
  
  @sorted: ->
    all = @all()
    all.sort (a, b) ->
      if a.active
        if b.active
          a.compare b
        else
          -1
      else if b.active
        1
      else
        a.compare b
    all
  
  @current: (id) ->
    @_current = @exists id if id?
    @_current