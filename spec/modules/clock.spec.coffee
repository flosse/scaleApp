describe "clock module", ->

  before ->
    @timeout = 3000
    @sa = window.scaleApp
    @div = document.createElement "div"
    @div.setAttribute "id", "clock"
    document
      .getElementsByTagName("body")[0]
      .appendChild @div
    @sa.register "clock", Clock
    @sa.start "clock"
    @secondsDiv = @div.getElementsByClassName("seconds")[0]
    @minutesDiv = @div.getElementsByClassName("minutes")[0]
    @getSeconds = -> @secondsDiv.innerText
    @getMinutes = -> @minutesDiv.innerText

  after ->
    @sa.stopAll()
    @sa.unregisterAll()

  it "can be registered", ->
    (expect typeof Clock).toEqual "function"
    (expect @sa.register "clock2", Clock).toBe true

  it "creates separate div with 'clock' as class attribute", ->
    (expect typeof Clock).toEqual "function"
    (expect @div.childNodes[0].getAttribute "class").toEqual "clock"

  it "can be paused", (done) ->
    s = @getSeconds()
    setTimeout((=>
      s2 = @getSeconds()
      (expect s).not.toEqual s2
      @sa.publish "clock/pause"
      s3 = @getSeconds()
      setTimeout((=>
        (expect s3).toEqual @getSeconds()
        done()
      ),1400)
    ),1400)

  it "can be resumed", (done) ->
    @sa.publish "clock/pause"
    s = @getSeconds()
    @sa.publish "clock/resume"
    setTimeout((=>
      (expect s).not.toEqual @getSeconds()
      done()
    ),1400)

  it "can be set", ->
    @sa.publish "clock/pause"
    @sa.publish "clock/set", (2 * 60 * 1000 + 3*1000)
    s = @getSeconds()
    (expect @getSeconds()  * 1).toEqual 3
    (expect @getMinutes() * 1).toEqual 2

  it "sends an event at a specific time", (done)->
    @sa.publish "clock/pause"
    @sa.publish "clock/set",      (5*60*1000 + 2000)
    @sa.publish "clock/setAlert", (5*60*1000 + 3000)
    @sa.on "clock/alert", =>
      (expect @getSeconds()  * 1).toEqual 3
      (expect @getMinutes() * 1).toEqual 5
      done()
    @sa.publish "clock/forward"
    @sa.publish "clock/resume"

  it "stops at a specific time", (done)->
    @sa.publish "clock/pause"
    @sa.publish "clock/set",     (60*1000 + 1000)
    @sa.publish "clock/setStop", (60*1000 + 2000)
    setTimeout((=>
      (expect @getSeconds() * 1).toEqual 2
      (expect @getMinutes() * 1).toEqual 1
      done()
    ),2400)
    @sa.publish "clock/forward"
    @sa.publish "clock/resume"

  it "can run reverse", (done) ->
    @sa.publish "clock/reverse"
    s = @getSeconds() * 1
    setTimeout((=>
      s -= 1
      s = 59 if s is -1
      (expect s).toEqual @getSeconds() * 1
      done()
    ),1100)

  it "can run reverse with a start time", (done) ->
    @sa.publish "clock/reverse", 2000
    s = @getSeconds() * 1
    (expect s).toEqual 2
    done()
