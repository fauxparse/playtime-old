ESCAPE_CHARACTERS = 
  "&": "&amp;"
  "<": "&lt;"
  ">": "&gt;"
  """: "&quot;"
  """: "&#39;"
  "/": "&#x2F;"
  "\n": "<br/>"

String::escape = ->
  @replace /[&<>"'\/\n]/g, (s) -> ESCAPE_CHARACTERS[s]

String::slugify = -> @.toLocaleLowerCase().replace(/[^a-z0-9]+/g, "-")
