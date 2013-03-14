class App.Controllers.Jesters.Edit extends App.Controllers.Stackable
  elements:
    "form" : "form"
    ".content" : "content"
    ".photo img" : "photo"

  events:
    "tap [rel=ok]" : "save"
    "tap [rel=photo]:not(.disabled)" : "choosePhoto"
    "submit form" : "submit"

  init: ->
    @el.addClass "edit-jester"
    super
    @html @view("jesters/edit")(jester: @jester)
    @$(".photo").toggle !@jester.isNew()
    @$("[type=file]").fileupload
      dataType: "json"
      add: (e, data) =>
        button = @$(".photo button")
        buttonText = button.text()
        button.addClass("disabled").text('Uploading…')
        data.submit().done (data) =>
          @photo.attr "src", data.files[0].url
          button.removeClass("disabled").text(buttonText)
          @jester.avatar = App.Models.Jester.records[@jester.id].avatar = data.files[0].url
          @jester.trigger "update", from: "photo"

  save: (e) ->
    @form.submit()

  submit: (e) ->
    e.stopPropagation()
    e.preventDefault()
    @jester.load @form.serializeObject()
    if errors = @jester.validate()
      for field in ["name", "email", "password"]
        @$("[name=#{field}]").nextAll("p").first().toggle errors.hasOwnProperty(field)
    else
      @jester.save()
      @stack.pop()

  choosePhoto: (e) ->
    evt = document.createEvent "Event"
    evt.initEvent "click", true, true
    @$("[type=file]")[0].dispatchEvent evt