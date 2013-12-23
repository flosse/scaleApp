require?("../../spec/nodeSetup")()

describe "submodule plugin", ->

  beforeEach ->
    if typeof require is "function"
      @scaleApp  = getScaleApp()
      @plugin    = require "../../dist/plugins/scaleApp.submodule"
      @permissionPlugin = require "../../dist/plugins/scaleApp.permission"
    else if window?
      @scaleApp  = window.scaleApp
      @plugin =  @scaleApp.plugins.submodule
      @permissionPlugin =  @scaleApp.plugins.permission

    @core = new @scaleApp.Core
    @core
      .use(@permissionPlugin)
      .use(@plugin, {use:[@permissionPlugin]})
      .boot()

  it "can start a submodule", (done) ->

    x = sinon.spy()

    mySubModule = (sb) ->
      init: -> x()
      destroy: -> done()

    myModule = (sb) ->
      init: ->
        (expect sb.sub).to.be.an "object"
        (expect sb.sub.register).to.be.a "function"
        (expect sb.sub.register "sub", mySubModule).to.equal sb
        (expect sb.sub.start "sub", {instanceId: "foo"}).to.equal sb

    @core.register "parent", myModule
    @core.start "parent"
    (expect x).to.have.been.called
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
    (expect x).to.be.true

  it "has methods to add/remove permissons if the permission plugin is registered", (done) ->

    spyA = sinon.spy()
    spyB = sinon.spy()

    mySubModule = (sb) ->
      init: ->
        sb.emit "a"
        sb.emit "b"
      destroy: ->

    myModule = (sb) ->
      init: ->
        sb.sub.register "sub", mySubModule
        (expect sb.sub.permission).to.be.an "object"
        (expect sb.sub.permission.add).to.be.a "function"
        (expect sb.sub.permission.remove).to.be.a "function"
        sb.sub.permission.add "foo", "emit", "b"
        sb.sub.on "a", spyA
        sb.sub.on "b", spyB
        sb.sub.start "sub", {instanceId: "foo"}
      destroy: ->
    @core.register "parent", myModule
    @core.start "parent"
    (expect spyA).not.to.have.been.called
    (expect spyB).to.have.been.called
    done()


  it "has methods to communicate with the submodules", (done) ->

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
          (expect cb1).not.to.have.been.called
          (expect cb2).to.have.been.called
          done()
        sb.sub.register "sub", mySubModule
        (expect sb.sub.on).to.be.a "function"
        (expect sb.sub.off).to.be.a "function"
        sb.sub.permission.add "foo", "on", "a channel"
        sb.sub.permission.add "foo", "emit", ["to parent", "done"]
        sb.sub.permission.add "bar", "emit", "a channel"
        sb.sub.start "sub", {instanceId: "foo"}
        sb.sub.start "sub", {instanceId: "bar"}
      destroy: ->
    @core.register "parent", myModule
    @core.permission.add "parent", "on", "to parent"
    @core.start "parent"

  it "provides an option to use the custom mediator", (done) ->

    mySubModule = (sb) -> init: -> sb.emit "x", "z"

    mediator = new @scaleApp.Mediator

    mediator.on "x", (y) ->
      (expect y).to.eql "z"
      done()

    myModule = (sb) ->
      init: ->
        sb.sub.register "sub", mySubModule
        sb.sub.start "sub"
    core = new @scaleApp.Core
    core
      .use(@plugin, {mediator: mediator})
      .boot()
      .register("parent", myModule)
      .start "parent"

  it "provides an option to use the global mediator", (done) ->

    mySubModule = (sb) -> init: -> sb.emit "event", "hello"

    myModule = (sb) ->
      init: ->
        sb.on "event", (data) ->
          (expect data).to.eql "hello"
          done()
        sb.sub.register "sub", mySubModule
        sb.sub.start "sub"
    core = new @scaleApp.Core
    core
      .use(@plugin, {useGlobalMediator: yes})
      .boot()
      .register("parent", myModule)
      .start "parent"

  it "provides an option for plugin inheritance", (done) ->

    foobarPlugin = (core) ->
      core.foobar = "baz"
      core.Sandbox::baz = "foobar"

    bazPlugin = (core) ->
      core.onlySub = 42
      core.Sandbox::only = "sub"

    mySubModule = (sb) ->
      init: ->
        (expect sb.sub).to.be.an "object"
        (expect sb.baz).to.equal "foobar"
        (expect sb._subCore.foobar).to.equal "baz"
        (expect core.foobar).to.equal "baz"
        (expect sb.only).to.equal "sub"
        (expect sb._subCore.onlySub).to.equal 42
        (expect core.onlySub).not.to.exist
        done()

    myModule = (sb) ->
      init: ->
        (expect sb.baz).to.equal "foobar"
        (expect core.onlySub).not.to.exist
        (expect sb.only).not.to.exist
        sb.sub.register "sub", mySubModule
        sb.sub.start "sub"

    core = new @scaleApp.Core
    core
      .use(@plugin, {inherit: true, use: bazPlugin})
      .use(foobarPlugin)
      .register("parent", myModule)
      .start("parent")
