require?("../../spec/nodeSetup")()

describe "permission plugin", ->

  beforeEach ->
    if typeof(require) is "function"
      @scaleApp  = getScaleApp()
      @plugin    = require "../../dist/plugins/scaleApp.permission"
    else if window?
      @scaleApp  = window.scaleApp
      @plugin    = @scaleApp.plugins.permission

    @core = new @scaleApp.Core
    @core.use(@plugin).boot()

    # helper method
    @run = (fn, id="id", cb=->) =>

        # create module
        mod = (sb) ->
          init: -> fn sb
          destroy: ->

        # register module
        @core.register id, mod, {i18n: @myLangObj }

        # start that moudle
        @core.start id, cb

  afterEach -> @core.stop()

  it "provides the method add", ->
    (expect @core.permission.add).to.be.a "function"

  it "provides the method remove", ->
    (expect @core.permission.remove).to.be.a "function"

  it "rejects all mediator methods if no explicit permission was defined", (done) ->

    test = (sb) ->
      (expect sb.on).to.be.a "function"
      (expect sb.on "x", ->).to.be.false
      (expect sb.off "x", ->).to.be.false
      (expect sb.emit "x").to.be.false
      (expect sb.emit "x").to.be.false
      done()

    @run test

  it "executes the required methods if a permission was defined", (done) ->

    @core.permission.add "anId", "on", "x"
    @core.permission.add "anId", "on", ["a", "b"]
    # add permission for all channels
    @core.permission.add "anId", "off", '*'

    @timeout = 500
    test = (sb) ->
      (expect sb.on "y", ->).to.be.false
      (expect sb.on "x", ->).not.to.be.false
      (expect sb.on "a", ->).not.to.be.false
      (expect sb.on "b", ->).not.to.be.false
      (expect sb.emit "x", ->).to.be.false
      (expect sb.off "x", ->).not.to.be.false
      (expect sb.off "a", ->).not.to.be.false
      (expect sb.off "unknown", ->).not.to.be.false
      done()

    @run test, "anId"

  it "can add permissions by an object", (done) ->

    @core.permission.add "anId",
      on: ["a", "b"]
      emit: "x"

    @core.permission.add anId: { off: '*' }

    test = (sb) ->
      (expect sb.on "y", ->).to.be.false
      (expect sb.on "a", ->).not.to.be.false
      (expect sb.on "b", ->).not.to.be.false
      (expect sb.emit "x", ->).not.to.be.false
      (expect sb.off "x", ->).not.to.be.false
      (expect sb.off "a", ->).not.to.be.false
      done()

    @run test, "anId"

  it "it can add all permissions to a channel", (done) ->

    @timeout = 1000
    (expect @core.permission.add "anId", '*', "x").to.be.true
    (expect @core.permission.add "anId", {'*': ["j", "k"]}).to.be.true

    test = (sb) ->
      (expect sb.on   "foo", ->).to.be.false
      (expect sb.on   "x", ->).not.to.be.false
      (expect sb.emit "x", ->).not.to.be.false
      (expect sb.off  "x", ->).not.to.be.false
      (expect sb.on   "j", ->).not.to.be.false
      (expect sb.emit "k", ->).not.to.be.false
      done()

    @run test, "anId"

  it "rejects a methods if no permission was defined", (done) ->

    @core.permission.add "oo", "on", "x"
    @core.permission.add "ii", "emit", "x"

    test = (sb) ->
      (expect sb.on "x", ->).to.be.false
      (expect sb.emit "x", ->).not.to.be.false
      done()

    @run test, "ii"

  it "removes a permission", (done) ->

    @core.permission.add "ee", "on", "x"
    @core.permission.add "ee", "emit", ["z", "w"]

    test = (sb) =>
      (expect sb.on "x", ->).not.to.be.false
      @core.permission.remove "ee", "on"
      (expect sb.on "x", ->).to.be.false
      (expect sb.emit "z", ->).not.to.be.false
      @core.permission.remove "ee", "emit", "z"
      (expect sb.emit "z", ->).to.be.false
      (expect sb.emit "w", ->).not.to.be.false
      done()

    @run test, "ee"
