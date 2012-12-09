require?("../nodeSetup")()

describe "submodule plugin", ->

  before ->
    if typeof require is "function"
      @scaleApp  = require "../../dist/scaleApp"
      @scaleApp.registerPlugin require "../../dist/plugins/scaleApp.submodule"
    else if window?
      @scaleApp  = window.scaleApp

  after ->
    @scaleApp.stopAll()
    @scaleApp.unregisterAll()

  it "can start a submodule", (done) ->

    x = false

    mySubModule = (sb) ->
      init: -> x = true
      destroy: -> done()

    myModule = (sb) ->
      init: ->
        (expect sb.register "sub", mySubModule).toBe true
        (expect sb.start "sub", {instanceId: "foo"}).toBe true
      destroy: ->

    (expect @scaleApp.register "parent", myModule).toBe true
    @scaleApp.start "parent"
    (expect x).toBe true
    @scaleApp.stop "parent"

  it "can stop a submodule", ->

    x = false

    mySubModule = (sb) ->
      init: ->
      destroy: -> x = true

    myModule = (sb) ->
      init: ->
        sb.register "sub", mySubModule
        sb.start "sub", {instanceId: "bar"}
        sb.stop "bar"
      destroy: ->

    @scaleApp.register "parent", myModule
    @scaleApp.start "parent"
    (expect x).toBe true
