require?("../../spec/nodeSetup")()

describe "i18n plugin", ->

  before ->
    if typeof(require) is "function"
      @scaleApp  = require "../../dist/scaleApp"
      @plugin    = require "../../dist/plugins/scaleApp.i18n"

    else if window?
      @scaleApp  = window.scaleApp
      @plugin    = @scaleApp.plugins.i18n

    @core = new @scaleApp.Core
    @core.use(@plugin).boot()

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
        @core.register "myId", mod, {i18n: @myLangObj }

        # start that module
        @core.start "myId", callback: cb

  it "provides the method getBrowserLanguage", ->
    (expect typeof @core.getBrowserLanguage ).toEqual "function"

  it "has a method for setting a language code", ->
    lang = "en-US"
    @core.i18n.setLanguage lang
    (expect lang).toEqual @core.i18n.getLanguage()

  it "has a method for setting a global object", ->
    (expect typeof @core.i18n.setGlobal).toEqual "function"
    (expect @core.i18n.setGlobal @core).toEqual true

  it "fires an event when the languages was changed", (done) ->

    cb = sinon.spy()
    scb = sinon.spy()

    @core.i18n.onChange cb

    test = (sb) =>
      sb.i18n.onChange scb
      @core.i18n.setLanguage "de-CH"

    @run test, ->
      (expect cb).toHaveBeenCalled()
      (expect scb).toHaveBeenCalled()
      done()

  describe "get text function", ->

    it "returns the global text if nothing was defined locally", (done) ->

      @core.i18n.setLanguage "de"
      @core.i18n.setGlobal @globalObj

      test = (sb) =>
        # yes is only defined globally
        (expect sb._ "yes" ).toEqual "ja"
        # helloWorld is only defined locally
        (expect sb._ "helloWorld" ).toEqual "Hallo Welt"
        done()

      @run test

    it "returns english string if current language is not supported", (done) ->
      test = (sb) =>
        @core.i18n.setLanguage( "es" )
        (expect sb._ "helloWorld" ).toEqual "Hello world"
        (expect sb.i18n.getLanguage()).toEqual "es"
        done()
      @run test

    it "returns base language string if current language is not supported", (done) ->
      test = (sb) =>
        @core.i18n.setLanguage "de-CH"
        (expect sb._ "helloWorld" ).toEqual "Hallo Welt"
        done()
      @run test

    it "returns the local language string if it is set", (done) ->
      @timeout = 1000
      @core.i18n.setGlobal "de": { hey: "Tach!" }
      test = (sb) =>
        (expect typeof sb.i18n.addLocal).toEqual "function"
        sb.i18n.addLocal {en: { time: "Time"}, de: {time: "Zeit"} }
        @core.i18n.setLanguage "de"
        (expect sb._ "time" ).toEqual "Zeit"
        (expect sb._ "hey" ).toEqual "Tach!"
        @core.i18n.setLanguage "en"
        (expect sb._ "time" ).toEqual "Time"
        done()
      @run test

    it "returns not the base language string if current language is supported", (done) ->
      test = (sb) =>
        @core.i18n.setLanguage "de-CH"
        (expect sb._ "hello" ).toEqual "Grüezi!"
        done()
      @run test

    it "returns the key itself if nothing was found", (done) ->
      @core.register "mod", (sb) ->
        init: =>
          (expect sb._ "nothing").toEqual "nothing"
          done()
        destroy: ->
      @core.start "mod"
