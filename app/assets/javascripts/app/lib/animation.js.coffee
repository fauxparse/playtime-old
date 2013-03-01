$.fn.transition = $.fn.animate unless $.support.transition

$.fn.animateIf = (flag, properties, etc...) ->
  if flag
    @transition properties, etc...
  else
    @css properties
    if etc.length and $.isFunction(callback = etc[etc.length - 1])
      callback.apply(@[0])

Spine.Controller.include
  after: (timeout, callback) ->
    setTimeout callback, timeout

  immediately: (callback) ->
    @after 0, callback
