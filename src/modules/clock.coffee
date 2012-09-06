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
    id = @sb.instanceId
    @sb.on "#{id}/pause",   @pause,   @
    @sb.on "#{id}/resume",  @resume,  @
    @sb.on "#{id}/set",     @set,     @
    @sb.on "#{id}/reverse", @reverse, @
    @sb.on "#{id}/forward", @forward, @
    @resume()

  resume: ->
    @set()
    @update()
    @timer = setInterval @update, 1000

  pause: -> clearInterval @timer

  set: (ev) ->
    @refDate = new Date
    if ev? and typeof ev is "number"
      @startDate = new Date 0,0
      @startDate.setMilliseconds ev
    else
      @startDate = @date or new Date @refDate.getTime()
    @date = new Date @startDate.getTime()
    @update()

  reverse: (ev) ->
    @runReverse = true
    @set ev

  forward: (ev) ->
    @runReverse = false
    @set ev

  update: =>
    d     = new Date
    diff  = d - @refDate
    diff = -diff if @runReverse
    @date = new Date (@startDate.getTime() +  diff)
    @h.textContent = getDigits @date.getHours()
    @m.textContent = getDigits @date.getMinutes()
    @s.textContent = getDigits @date.getSeconds()

  destroy: ->
    @pause()
    @container.innerHTML = ''

window.Clock = Clock
