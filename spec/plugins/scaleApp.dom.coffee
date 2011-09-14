describe "dom plugin", ->

  testIt = ->
  dummy = { a: "dummy" }
  run = -> scaleApp.start "myId"

  mod = (@sb) ->
    init: =>
      testIt @sb
    destroy: ->

  beforeEach ->
    scaleApp.register "myId", mod

  afterEach ->
    scaleApp.stopAll()
    scaleApp.unregisterAll()

  it "installs itself to the sandbox", ->

    cb = jasmine.createSpy "a callback"

    testIt = (sb) ->
      (expect typeof sb.getContainer).toEqual "function"
      cb()

    run()
    (expect cb).toHaveBeenCalled()

  it "returns the object that was defined in the option object", ->
    testIt = (sb) ->
      (expect sb.getContainer()).toEqual dummy
    scaleApp.start "myId", { options: { container: dummy } }

  it "returns the dom object which id was defined in the option object", ->

    cb = jasmine.createSpy "a callback"

    div = document.createElement "div"
    div.setAttribute "id", "dummy"
    document.body.appendChild div
    console.log document.body

    testIt = (sb) ->
      (expect sb.getContainer()).toEqual div
      cb()
    scaleApp.start "myId", { options: { container: "dummy" } }
    (expect cb).toHaveBeenCalled()
