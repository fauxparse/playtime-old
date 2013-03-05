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

String::hashCode = ->
  hash = 0
  i = 0
  while i < @length
    char = @charCodeAt i
    hash = ((hash << 5) - hash) + char
    hash &= hash
    i++
  hash
