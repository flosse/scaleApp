template =
  """
  <div class="clock">
    <span class="hours"></span>
    <span class="delimiter">:</span>
    <span class="minutes"></span>
    <span class="delimiter">:</span>
    <span class="seconds"></span>
  </div>
  """

getDigits = (n) ->
  n = n.toString()
  n = "0" + n if n.length is 1
  n

class Clock

  constructor: (@sb) ->

  init: (opt) ->
    @container = @sb.getContainer()
    @container.innerHTML = template
    @h = @container.getElementsByClassName("hours"  )[0]
    @m = @container.getElementsByClassName("minutes")[0]
    @s = @container.getElementsByClassName("seconds")[0]
    @update()
    @timer = setInterval @update, 1000


  update: =>
    d = new Date
    @h.textContent = getDigits d.getHours()
    @m.textContent = getDigits d.getMinutes()
    @s.textContent = getDigits d.getSeconds()

  destroy: ->
    clearInterval @timer
    @container.innerHTML = ''

window.Clock = Clock
