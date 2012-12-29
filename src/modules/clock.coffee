###
Copyright (c) 2012 Markus Kohlhase <mail@markus-kohlhase.de>
###

secondsTemplate = ->
  if @showSeconds
    """
    <span class="delimiter">:</span>
    <span class="seconds"></span>
    """
  else ''

template = ->
  """
  <div class="clock">
    <span class="hours"></span>
    <span class="delimiter">:</span>
    <span class="minutes"></span>
    #{secondsTemplate.call @}
  </div>
  """

getDigits = (n) ->
  n = n.toString()
  n = "0" + n if n.length is 1
  n

getTimeObject = (t) ->
  if typeof t is "number"
    d = new Date 0,0
    d.setMilliseconds t
  else if t instanceof Date
    d = t
  s: d.getSeconds()
  m: d.getMinutes()
  h: d.getHours()

getTime = (t) -> new Date(0,0,0,t.h,t.m,t.s).getTime()

compare = (t1, t2) ->
  a = getTime t1
  b = getTime t2
  if a is b then 0 else if a > b then 1 else -1

class Clock

  constructor: (@sb) ->

  init: (opt) ->
    { start, stop, min, max, reverse, @loop, @showSeconds } = opt
    @minTime    = getTimeObject min   if min?
    @maxTime    = getTimeObject max   if max?
    @startTime  = getTimeObject start if start?
    @showSeconds ?= true
    @timerIntervall = if @showSeconds then 1000 else 10000
    @setStop stop
    @setAlert opt.alert
    @runReverse = true if reverse
    @container = @sb.getContainer()
    @container.innerHTML = template.call @
    @hDiv = @container.getElementsByClassName("hours"  )[0]
    @mDiv = @container.getElementsByClassName("minutes")[0]
    @sDiv = @container.getElementsByClassName("seconds")?[0]
    id = @sb.instanceId
    @sb.on "#{id}/pause",    @pause,    @
    @sb.on "#{id}/resume",   @resume,   @
    @sb.on "#{id}/set",      @set,      @
    @sb.on "#{id}/reverse",  @reverse,  @
    @sb.on "#{id}/forward",  @forward,  @
    @sb.on "#{id}/setAlert", @setAlert, @
    @sb.on "#{id}/setStop",  @setStop,  @
    @set @startTime
    @resume()

  resume: ->
    @set()
    @timer = setInterval @update, @timerIntervall

  pause: -> clearInterval @timer

  set: (ev) ->
    if typeof ev is "object"
      ev = ((ev.h *60 + ev.m) * 60 + ev.s) * 1000
    @refDate = new Date
    if ev? and typeof ev is "number"
      @startDate = new Date 0,0
      @startDate.setMilliseconds ev
    else
      @startDate = @date or new Date @refDate.getTime()
    @date = new Date @startDate.getTime()
    @render getTimeObject @date

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

  minReached: (t) -> @minTime and compare(t, @minTime) < 0

  maxReached: (t) -> @maxTime and compare(t, @maxTime) > 0

  onMinReached: ->
    if @loop
      if not @runReverse
        @onMaxReached()
      else
        if @maxTime then @set @maxTime else @set h:59, m:59, s:59
    else
      @pause()
      @render @minTime

  onMaxReached: ->
    if @loop
      if @runReverse
        @onMinReached()
      else
        if @minTime then @set @minTime else @set 0
    else
      @pause()
      @render @maxTime

  update: =>
    diff  = (new Date) - @refDate
    diff = -diff if @runReverse
    date = new Date (@startDate.getTime() +  diff)
    t = getTimeObject date
    if @alertTime and compare(@alertTime,t) is 0
      @render t
      @sb.emit "#{@sb.instanceId}/alert" if alert
    if @stopTime and compare(@stopTime,t) is 0
      @pause()
      @render t
      return
    if @minReached t
      @onMinReached()
      return
    if @maxReached t
      @onMaxReached()
      return
    @render t
    @date = date

  render: (t) ->
    @hDiv.textContent = getDigits t.h
    @mDiv.textContent = getDigits t.m
    @sDiv.textContent = getDigits t.s if @showSeconds

  destroy: ->
    @pause()
    @container.innerHTML = ''

window.Clock = Clock
