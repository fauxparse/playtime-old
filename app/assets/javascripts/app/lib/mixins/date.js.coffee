Date::isFriday   = -> @getDay() == 5
Date::isSaturday = -> @getDay() == 6

Date::plus = (days = 1, unit = Date.DAY) ->
  new Date(@getTime() + days * Date.DAY)
  
Date::nextFriday = ->
  @plus 5 - @getDay()

Date.DAY = 24 * 60 * 60 * 1000

Date.months = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ]
Date.weekdays = [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ]

Date.formats =
  "a": -> Date.weekdays[@getDay()].substring(0, 3)
  "A": -> Date.weekdays[@getDay()]
  "b": -> Date.months[@getMonth()].substring(0, 3)
  "B": -> Date.months[@getMonth()]
  "c": -> @toLocaleString()
  "d": -> @getDate().toString()
  "e": -> Date.weekdays[@getDay()].substring(0, 1)
  "F": -> "#{@getFullYear()}-#{(@getMonth() + 1).pad(2)}-#{@getDate().pad(2)}"
  "H": -> @getHours().pad(2)
  "I": -> "#{(@getHours() % 12) || 12}"
  "j": -> @getDayOfYear()
  "L": -> @getMilliseconds().pad(3)
  "m": -> (@getMonth() + 1).pad(2)
  "M": -> @getMinutes().pad(2)
  "N": -> @getMilliseconds().pad(3)
  "o": -> @getMonth() + 1
  "p": -> if @getHours() < 12 then "AM" else "PM"
  "P": -> if @getHours() < 12 then "am" else "pm"
  "S": -> @getSeconds().pad(2)
  "s": -> Math.floor(@getTime() / 1000)
  "U": -> @getWeekOfYear()
  "w": -> @getDay()
  "W": -> @getWeekOfYear(1)
  "y": -> @getFullYear() % 100
  "Y": -> @getFullYear()
  "x": -> @toLocaleDateString()
  "X": -> @toLocaleTimeString()
  "z": -> Math.floor((z = -@getTimezoneOffset()) / 60).pad(2, true) + (Math.abs(z) % 60).pad(2)
  "Z": -> /\(([^\)]*)\)$/.exec(@toString())[1]

Date::format = (fmt = "%F") ->
  parts = (fmt || "%c").split "%%"
  for own char, callback of Date.formats
    r = new RegExp("%#{char}", "g")
    parts = (part.replace(r, => callback.apply(this)) for part in parts)
  parts.join "%"
  
Date::getDayOfYear = -> Math.ceil((@getTime() - new Date(@getFullYear(), 0, 1).getTime()) / 24 / 60 / 60 / 1000)

Date::getWeekOfYear = (start = 0) ->
  Math.floor((@getDayOfYear() - (start + 7 - new Date(@getFullYear(), 0, 1).getDay()) % 7) / 7) + 1
  
Date.fromDB = (value) ->
  [y, m, d] = value.split("-").map((n) -> parseInt(n, 10))
  new Date y, m - 1, d, 5

Date::toArray = ->
  [ @getFullYear(), @getMonth() + 1, @getDate(), @getHours(), @getMinutes(), @getSeconds() ]
  
Date.range = (dates...) ->
  first = dates[0]
  last = dates[dates.length - 1]
  [y1, m1, d1] = first.toArray()
  [y2, m2, d2] = last.toArray()
  if m1 == m2
    if d1 == d2
      "#{first.format("%d %B")}"
    else
      "#{first.format("%d")}–#{last.format("%d %b")}"
  else
    "#{first.format("%d %b")} – #{last.format("%d %b")}"
  
