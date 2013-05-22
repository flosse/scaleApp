describe "clock module", ->

  before ->
    @timeout = 3000
    @sa = window.scaleApp
    @core = new @sa.Core
    @core.use(@sa.plugins.dom).boot()
    @div = document.createElement "div"
    @div.setAttribute "id", "clock"
    document
      .getElementsByTagName("body")[0]
      .appendChild @div
    @core.register "clock", @sa.modules.Clock
    @core.start "clock"
    @getSeconds = ->
      @div.getElementsByClassName("seconds")[0].innerText
    @getMinutes = ->
      @div.getElementsByClassName("minutes")[0].innerText

  after -> @core.stopAll()

  it "is a function", ->
    (expect typeof @sa.modules.Clock).toEqual "function"

  it "creates separate div with 'clock' as class attribute", ->
    (expect @div.childNodes[0].getAttribute "class").toEqual "clock"

  it "can be paused", (done) ->
    s = @getSeconds()
    setTimeout((=>
      s2 = @getSeconds()
      (expect s).not.toEqual s2
      @core.emit "clock/pause"
      s3 = @getSeconds()
      setTimeout((=>
        (expect s3).toEqual @getSeconds()
        done()
      ),1400)
    ),1400)

  it "can be resumed", (done) ->
    @core.emit "clock/pause"
    s = @getSeconds()
    @core.emit "clock/resume"
    setTimeout((=>
      (expect s).not.toEqual @getSeconds()
      done()
    ),1400)

  it "can be set", ->
    @core.emit "clock/pause"
    @core.emit "clock/set", (2 * 60 * 1000 + 3*1000)
    @core.emit "clock/resume"
    s = @getSeconds()
    (expect @getSeconds()  * 1).toEqual 3
    (expect @getMinutes() * 1).toEqual 2

  it "sends an event at a specific time", (done)->
    @core.emit "clock/pause"
    @core.emit "clock/set",      (5*60*1000 + 2000)
    @core.emit "clock/setAlert", (5*60*1000 + 3000)
    @core.on "clock/alert", =>
      (expect @getSeconds()  * 1).toEqual 3
      (expect @getMinutes() * 1).toEqual 5
      done()
    @core.emit "clock/forward"
    @core.emit "clock/resume"

  it "stops at a specific time", (done)->
    @core.emit "clock/pause"
    @core.emit "clock/set",     (60*1000 + 1000)
    @core.emit "clock/setStop", (60*1000 + 2000)
    setTimeout((=>
      (expect @getSeconds() * 1).toEqual 2
      (expect @getMinutes() * 1).toEqual 1
      done()
    ),2400)
    @core.emit "clock/forward"
    @core.emit "clock/resume"

  it "can run reverse", (done) ->
    @core.emit "clock/reverse"
    s = @getSeconds() * 1
    setTimeout((=>
      s -= 1
      s = 59 if s is -1
      (expect s).toEqual @getSeconds() * 1
      done()
    ),1100)

  it "can run reverse with a start time", (done) ->
    @core.emit "clock/reverse", 2000
    s = @getSeconds() * 1
    (expect s).toEqual 2
    done()

  it "can configured with a min time", (done) ->
    @core.stop "clock"
    @core.start "clock",
      options: min: 60000
    @core.emit "clock/reverse", 60010, =>
      setTimeout((=>
        (expect @getMinutes() * 1).toEqual 1
        (expect @getSeconds() * 1).toEqual 0
        done()
      ),1100)

  it "can configured with a max time", (done) ->
    @core.stop "clock"
    @core.start "clock",
      options: max: 60000
    @core.emit "clock/set", 59990, =>
      setTimeout((=>
        (expect @getMinutes() * 1).toEqual 1
        (expect @getSeconds() * 1).toEqual 0
        done()
      ),1100)

  it "can configured with a loop option", (done) ->
    @core.stop "clock"
    @core.start "clock",
      options:
        start: 62000
        min:   1000
        max:   62000
        loop:  true

    setTimeout((=>
      (expect @getMinutes() * 1).toEqual 0
      (expect @getSeconds() * 1).toEqual 1
      done()
    ),1100)
