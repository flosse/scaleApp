###
Copyright (c) 2012 Markus Kohlhase <mail@markus-kohlhase.de>
###

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

getTimeObject = (t) ->
  d = new Date 0,0
  d.setMilliseconds t
  s: d.getSeconds()
  m: d.getMinutes()
  h: d.getHours()

class Clock

  constructor: (@sb) ->

  init: (opt) ->
    @container = @sb.getContainer()
    @container.innerHTML = template
    @hDiv = @container.getElementsByClassName("hours"  )[0]
    @mDiv = @container.getElementsByClassName("minutes")[0]
    @sDiv = @container.getElementsByClassName("seconds")[0]
    id = @sb.instanceId
    @sb.on "#{id}/pause",    @pause,    @
    @sb.on "#{id}/resume",   @resume,   @
    @sb.on "#{id}/set",      @set,      @
    @sb.on "#{id}/reverse",  @reverse,  @
    @sb.on "#{id}/forward",  @forward,  @
    @sb.on "#{id}/setAlert", @setAlert, @
    @sb.on "#{id}/setStop",  @setStop,  @
    @alertTime = false
    @stopTime  = false
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

  setAlert: (t) ->
    @alertTime = getTimeObject t if typeof t is "number"

  setStop: (t) ->
    @stopTime = getTimeObject t if typeof t is "number"

  reverse: (ev) ->
    @runReverse = true
    @set ev

  forward: (ev) ->
    @runReverse = false
    @set ev

  check: ->
    if @alertTime.s is @s and
       @alertTime.m is @m and
       @alertTime.h is @h
      @sb.emit "#{@sb.instanceId}/alert"
    if @stopTime.s is @s and
       @stopTime.m is @m and
       @stopTime.h is @h
      @pause()

  update: =>
    diff  = (new Date) - @refDate
    diff = -diff if @runReverse
    @date = new Date (@startDate.getTime() +  diff)
    @h = @date.getHours()
    @m = @date.getMinutes()
    @s = @date.getSeconds()
    @hDiv.textContent = getDigits @h
    @mDiv.textContent = getDigits @m
    @sDiv.textContent = getDigits @s
    @check()

  destroy: ->
    @pause()
    @container.innerHTML = ''

window.Clock = Clock
