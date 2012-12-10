require?("../nodeSetup")()

describe "submodule plugin", ->

  before ->
    if typeof require is "function"
      @scaleApp  = require "../../dist/scaleApp"
      @scaleApp.registerPlugin require "../../dist/plugins/scaleApp.submodule"
      @permissionPlugin = require "../../dist/plugins/scaleApp.permission"
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
        (expect typeof sb.sub.register).toBe "function"
        (expect sb.sub.register "sub", mySubModule).toBe true
        (expect sb.sub.start "sub", {instanceId: "foo"}).toBe true
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
        sb.sub.register "sub", mySubModule
        sb.sub.start "sub", {instanceId: "bar"}
        sb.sub.stop "bar"
      destroy: ->

    @scaleApp.register "parent", myModule
    @scaleApp.start "parent"
    (expect x).toBe true

  it "has methods to add/remove permissons if the permission plugin is registered", (done) ->

    @scaleApp.registerPlugin @permissionPlugin
    sa = @scaleApp

    mySubModule = (sb) ->
      init: ->
        (expect sb.emit "a").toBe false
        (expect sb.emit "b").not.toBe false
        sa.unregisterPlugin "permission"
        done()
      destroy: ->

    myModule = (sb) ->
      init: ->
        sb.sub.register "sub", mySubModule
        (expect typeof sb.permission).toBe "object"
        (expect typeof sb.permission.add).toBe "function"
        (expect typeof sb.permission.remove).toBe "function"
        sb.permission.add "foo", "emit", "b"
        sb.sub.start "sub", {instanceId: "foo"}
      destroy: ->
    @scaleApp.register "parent", myModule
    @scaleApp.start "parent"
