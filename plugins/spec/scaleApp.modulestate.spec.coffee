require?("../../spec/nodeSetup")()

describe "modulestate plugin", ->

  if typeof(require) is "function"
    scaleApp  = require "../../dist/scaleApp"
    plugin    = require "../../dist/plugins/scaleApp.modulestate"

  else if window?
    scaleApp  = window.scaleApp
    plugin    = scaleApp.plugins.modulestate

  before ->
    @core = new scaleApp.Core
    @core.stop()
    @core
      .use(plugin)
      .boot()
      .register "mod", (sb) ->
        init: ->
        destroy: ->


  it "calls a registered method on instatiation", ->

    initCB = sinon.spy()
    modCB  = sinon.spy()
    instCB = sinon.spy()

    m = -> init: ->

    @core.state.on "init", initCB
    @core.state.on "init/mod", modCB
    @core.state.on "init/mod/x", instCB
    @core.start "mod", instanceId: "x"
    (expect initCB.callCount).to.equal 1
    (expect modCB.callCount).to.equal 1
    (expect instCB.callCount).to.equal 1
    @core.start "mod", instanceId: "y"
    (expect initCB.callCount).to.equal 2
    (expect modCB.callCount).to.equal 2
    (expect instCB.callCount).to.equal 1
    @core.register("12345",m).start "12345"
    (expect initCB.callCount).to.equal 3
    (expect modCB.callCount).to.equal 2
    (expect instCB.callCount).to.equal 1

  it "calls a registered method on destruction", (done) ->
    fn = (data, channel) ->
      (expect channel).to.equal "destroy/mod"
      done()
    @core.state.on "destroy/mod", fn
    @core.start "mod"
    @core.stop "mod"

  it "passes the moduleId and instanceId", (done) ->
    fn = (ev, channel) ->
      (expect channel).to.equal "init"
      (expect ev).to.eql {moduleId: "mod", instanceId: "33"}
      done()
    @core.state.on "init", fn, "mod"
    @core.start "mod", instanceId: "33"
