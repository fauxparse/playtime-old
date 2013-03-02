class App.Controllers.Jesters.Edit extends App.Controllers.Stackable
  elements:
    "form" : "form"

  events:
    "tap [rel=ok]" : "save"
    "submit form" : "submit"

  init: ->
    @el.addClass "edit-jester"
    super
    @html @view("jesters/edit")(jester: @jester)

  save: (e) ->
    @form.submit()

  submit: (e) ->
    e.stopPropagation()
    e.preventDefault()
    @jester.fromForm(@form)
    if errors = @jester.validate()
      for field in ["name", "email", "password"]
        @$("[name=#{field}]").nextAll("p").first().toggle errors.hasOwnProperty(field)
    else
      @jester.save()
      @stack.pop()
