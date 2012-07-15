require?("../nodeSetup")()

describe "i18n plugin", ->

  before ->
    if typeof(require) is "function"
      @scaleApp  = require "../../src/scaleApp"
      @scaleApp.registerPlugin require "../../src/plugins/scaleApp.i18n"

    else if window?
      @scaleApp  = window.scaleApp

    @myLangObj =
      en:
        helloWorld: "Hello world"
      de:
        helloWorld: "Hallo Welt"
        hello: "Hallo"
      "de-CH":
        hello: "Grüezi!"
      es:
        something: "??"

    @globalObj =
      en: { yes: "yes" }
      de: { yes: "ja"  }

    # helper method
    @run = (fn, cb=->) =>

        # create module
        mod = (sb) ->
          init: -> fn sb
          destroy: ->

        # register module
        @scaleApp.register "myId", mod, {i18n: @myLangObj }

        # start that moudle
        @scaleApp.start "myId", callback: cb

  after ->
    @scaleApp.stopAll()
    @scaleApp.unregisterAll()

  it "provides the method getBrowserLanguage", ->
    (expect typeof @scaleApp.i18n.getBrowserLanguage ).toEqual "function"

  it "has a method for setting a language code", ->
    lang = "en-US"
    @scaleApp.i18n.setLanguage lang
    (expect lang).toEqual @scaleApp.i18n.getLanguage()

  it "has a method for setting a global object", ->
    (expect typeof @scaleApp.i18n.setGlobal).toEqual "function"
    (expect @scaleApp.i18n.setGlobal @globalObj).toEqual true

  it "fires an event if the languages has changed", (done) ->

    cb = sinon.spy()
    scb = sinon.spy()

    @scaleApp.i18n.subscribe cb

    test = (sb) =>
      sb.i18n.subscribe scb
      @scaleApp.i18n.setLanguage "de-CH"

    @run test, ->
      (expect cb).toHaveBeenCalled()
      (expect scb).toHaveBeenCalled()
      done()

  describe "get text function", ->

    it "returns the global text if nothing was defined locally", (done) ->

      @scaleApp.i18n.setLanguage "de"
      @scaleApp.i18n.setGlobal @globalObj

      test = (sb) =>
        # yes is only defined globally
        (expect sb._ "yes" ).toEqual "ja"
        # helloWorld is only defined locally
        (expect sb._ "helloWorld" ).toEqual "Hallo Welt"
        done()

      @run test

    it "returns english string if current language is not supported", (done) ->
      test = (sb) =>
        @scaleApp.i18n.setLanguage( "es" )
        (expect sb._ "helloWorld" ).toEqual "Hello world"
        (expect sb.getLanguage()).toEqual "es"
        done()
      @run test

    it "returns base language string if current language is not supported", (done) ->
      test = (sb) =>
        @scaleApp.i18n.setLanguage "de-CH"
        (expect sb._ "helloWorld" ).toEqual "Hallo Welt"
        done()
      @run test

    it "returns not the base language string if current language is supported", (done) ->
      test = (sb) =>
        @scaleApp.i18n.setLanguage "de-CH"
        (expect sb._ "hello" ).toEqual "Grüezi!"
        done()
      @run test

    it "returns the key itself if nothing was found", (done) ->
      @scaleApp.register "mod", (sb) ->
        init: =>
          (expect sb._ "nothing").toEqual "nothing"
          done()
        destroy: ->
      @scaleApp.start "mod"
