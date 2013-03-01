class App.Models.Note extends Spine.Model
  @configure "Note", "author_id", "content", "updated_at"
  @extend Spine.Model.Ajax

  author: (jester) ->
    @author_id = jester.id or jester if jester?
    App.Models.Jester.exists(@author_id)
    
  content: (content) ->
    @_content = content if content?
    @_content or ""

  html: -> @content().escape()
  
  time: (time) -> 
    @updated_at = time if time?
    switch typeof @updated_at
      when "string" then new Date(Date.parse(@updated_at))
      else @updated_at
    
  empty: ->
    !(@content() + "").replace(/\s+/g, "")

  changeID: (id) ->
    oldID = @id
    super
    @trigger "changeID", oldID, @id