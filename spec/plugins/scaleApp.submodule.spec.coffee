require?("../nodeSetup")()

describe "submodule plugin", ->

  before ->
    if typeof require is "function"
      @scaleApp  = getScaleApp()
      @scaleApp.plugin.register require "../../dist/plugins/scaleApp.submodule"
      @permissionPlugin = require "../../dist/plugins/scaleApp.permission"
      @scaleApp.plugin.register @permissionPlugin
    else if window?
      @scaleApp  = window.scaleApp
    @core = new @scaleApp.Core

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

    (expect @core.register "parent", myModule).toBe true
    @core.start "parent"
    (expect x).toBe true
    @core.stop "parent"

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

    @core.register "parent", myModule
    @core.start "parent"
    (expect x).toBe true

  it "has methods to add/remove permissons if the permission plugin is registered", (done) ->

    mySubModule = (sb) ->
      init: ->
        (expect sb.emit "a").toBe false
        (expect sb.emit "b").not.toBe false
        done()
      destroy: ->

    myModule = (sb) ->
      init: ->
        sb.sub.register "sub", mySubModule
        (expect typeof sb.sub.permission).toBe "object"
        (expect typeof sb.sub.permission.add).toBe "function"
        (expect typeof sb.sub.permission.remove).toBe "function"
        sb.sub.permission.add "foo", "emit", "b"
        sb.sub.start "sub", {instanceId: "foo"}
      destroy: ->
    @core.register "parent", myModule
    @core.start "parent"

  it "has methods to communicat with the submodules", (done) ->

    cb1 = new sinon.spy()
    cb2 = new sinon.spy()

    mySubModule = (sb) ->
      init: ->
        switch sb.instanceId
          when "foo"
            sb.on "a channel", ->
              sb.emit "to parent"
              sb.emit "done"
          when "bar"
            sb.emit "a channel"
      destroy: ->

    myModule = (sb) ->
      init: ->
        sb.on "to parent", cb1
        sb.sub.on "to parent", cb2
        sb.sub.on "done", ->
          (expect cb1).not.toHaveBeenCalled()
          (expect cb2).toHaveBeenCalled()
          done()
        sb.sub.register "sub", mySubModule
        (expect typeof sb.sub.on).toBe "function"
        (expect typeof sb.sub.off).toBe "function"
        sb.sub.permission.add "foo", "on", "a channel"
        sb.sub.permission.add "foo", "emit", ["to parent", "done"]
        sb.sub.permission.add "bar", "emit", "a channel"
        sb.sub.start "sub", {instanceId: "foo"}
        sb.sub.start "sub", {instanceId: "bar"}
      destroy: ->
    @core.register "parent", myModule
    @core.permission.add "parent", "on", "to parent"
    @core.start "parent"
