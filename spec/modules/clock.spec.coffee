describe "clock module", ->

  before ->
    @sa = window.scaleApp
    @div = document.createElement "div"
    @div.setAttribute "id", "clock"
    document
      .getElementsByTagName("body")[0]
      .appendChild @div

  after ->
    @sa.stopAll()
    @sa.unregisterAll()

  it "can be registered", ->
    (expect typeof Clock).toEqual "function"
    (expect @sa.register "clock", Clock).toBe true

  it "creates separate div with 'clock' as class attribute", ->
    @sa.register "clock", Clock
    (expect @sa.start "clock").toEqual true
    (expect typeof Clock).toEqual "function"
    (expect @div.childNodes[0].getAttribute "class").toEqual "clock"
