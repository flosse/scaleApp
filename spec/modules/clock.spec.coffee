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
    @getSeconds = -> @secondsDiv.innerText

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
      ),1200)
    ),1200)

  it "can be resumed", (done) ->
    @sa.publish "clock/pause"
    s = @getSeconds()
    @sa.publish "clock/resume"
    setTimeout((=>
      (expect s).not.toEqual @getSeconds()
      done()
    ),1200)

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
