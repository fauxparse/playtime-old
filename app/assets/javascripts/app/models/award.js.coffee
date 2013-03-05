class App.Models.Award extends Spine.Model
  @configure 'Award', 'author_id', 'nominees', 'content', 'category', 'created_at'
  @extend Spine.Model.Ajax

  constructor: ->
    @likes = []
    super

  categorySlug: ->
    (@category or "").slugify()

  date: ->
    if @created_at
      Date.fromDB @created_at
    else
      new Date

  author: ->
    App.Models.Jester.exists @author_id

  editableBy: (jester) ->
    jester.admin or jester.eql(@author())

  likedBy: (jester, toggle) ->
    if toggle?
      $.ajax
        url: @url() + "/likes"
        type: if toggle then "post" else "delete"
        dataType: "json"
      if toggle
        @likes.push jester.id
      else
        @likes = (id for id in @likes when id isnt jester.id)
    jester.id in @likes

  changeID: (id) ->
    oldID = @id
    super
    @trigger "changeID", oldID, @id

  @categories: ->
    categories = {}
    @each (award) ->
      key = award.categorySlug().hashCode()
      categories[key] or= []
      categories[key].push award
    list = ([key, awards[0].category, awards] for own key, awards of categories)
    list.sort (a, b) -> a[1].toLocaleLowerCase().localeCompare(b[1].toLocaleLowerCase())
    list

  @category: (slug) ->
    (award for award in @all() when award.categorySlug() is slug)
