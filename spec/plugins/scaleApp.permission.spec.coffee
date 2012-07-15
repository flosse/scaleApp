require?("../nodeSetup")()

describe "permission plugin", ->

  beforeEach ->
    if typeof(require) is "function"
      @scaleApp  = require "../../src/scaleApp"
      @plugin    = require "../../src/plugins/scaleApp.permission"
      @scaleApp.registerPlugin @plugin
    else if window?
      @scaleApp  = window.scaleApp

    # helper method
    @run = (fn, id="id", cb=->) =>

        # create module
        mod = (sb) ->
          init: -> fn sb
          destroy: ->

        # register module
        @scaleApp.register id, mod, {i18n: @myLangObj }

        # start that moudle
        @scaleApp.start id, callback: cb

  afterEach ->
    @scaleApp.stopAll()
    @scaleApp.unregisterAll()

  it "provides the method add", ->
    (expect typeof @scaleApp.permission.add).toEqual "function"

  it "provides the method remove", ->
    (expect typeof @scaleApp.permission.remove).toEqual "function"

  it "rejects all mediator methods if no explicit permission was defined", (done) ->

    test = (sb) ->
      (expect typeof sb.subscribe).toEqual "function"
      (expect sb.subscribe "x", ->).toBe false
      (expect sb.unsubscribe "x", ->).toBe false
      (expect sb.publish "x").toBe false
      done()

    @run test

  it "executes the required methods if a permission was defined", (done) ->

    @scaleApp.permission.add "anId", "subscribe"

    test = (sb) ->
      (expect sb.subscribe "x", ->).not.toEqual false
      (expect sb.publish "x", ->).toBe false
      done()

    @run test, "anId"

  it "rejects a methods if no permission was defined", (done) ->

    @scaleApp.permission.add "oo", "subscribe"
    @scaleApp.permission.add "ii", "publish"

    test = (sb) ->
      (expect sb.subscribe "x", ->).toBe false
      (expect sb.publish "x", ->).not.toBe false
      done()

    @run test, "ii"

  it "removes a permission", (done) ->

    @scaleApp.permission.add "ee", "subscribe"

    test = (sb) =>
      (expect sb.subscribe "x", ->).not.toBe false
      @scaleApp.permission.remove "ee", "subscribe"
      (expect sb.subscribe "x", ->).toBe false
      done()

    @run test, "ee"

