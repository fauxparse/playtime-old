Number::pad = (digits, signed) ->
  s = Math.abs(@).toString()
  s = "0" + s while s.length < digits
  (if @ < 0 then "-" else (if signed then "+" else "")) + s

Number::toSignedString = -> (@ < 0 ? "" : "+") + @

Number::percentage = ->
  p = (Math.round(@ * 10000) / 100).toString()
  p += "0" if /\.\d?$/.test(p)
  p + "%"

Math.trunc = (number) -> Math[if number < 0 then "ceil" else "floor"](number)

Math.sgn = (number) -> if number < 0 then -1 else 1
