require?("../nodeSetup")()

describe "util plugin", ->

  before ->

    if typeof(require) is "function"
      @scaleApp  = require "../../src/scaleApp"
      @scaleApp.registerPlugin require "../../src/plugins/scaleApp.util"

    else if window?
      @scaleApp  = window.scaleApp

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

  it "installs it to the sandbox", (done) ->

    @run (sb) ->
      (expect typeof sb.countObjectKeys).toEqual "function"
      (expect typeof sb.mixin).toEqual "function"
      done()


  describe "countObjectKeys", ->

    it "works correctly", (done) ->

      @run (sb) ->
        (expect sb.countObjectKeys { a:"a", b: "", c: 123 }).toEqual 3
        (expect sb.countObjectKeys [ "a", false, 123, true ]).toEqual 4
        done()


  describe "mixin", ->

    it "extends an object", (done) ->

      @run (sb) ->
        receivingObject = { a: "original", d: 55 }
        givingObject = { a: "one", b: "two", c: ["three"] }
        sb.mixin receivingObject, givingObject
        (expect receivingObject).toEqual { a: "original", b: "two", c: ["three"], d: 55 }
        done()

    it "extends a class with an object", (done) ->

      receivingClass = ->
      receivingClass:: = { a: "original", d: 55 }
      expected = { a: "original", b: "two", c: ["three"], d: 55 }
      givingObject = { a: "one", b: "two", c: ["three"] }

      @run (sb) ->
        sb.mixin receivingClass, givingObject
        (expect receivingClass:: ).toEqual expected
        (expect givingObject ).toEqual { a: "one", b: "two", c: ["three"] }
        done()

    it "extends an object with a class", (done) ->

      receivingObject = { a: "original", d: 55 }
      givingClass = ->
      givingClass:: = { a: "one", b: "two", c: ["three"] }

      @run (sb) ->
        sb.mixin receivingObject, givingClass
        (expect receivingObject).toEqual { a: "original", b: "two", c: ["three"], d: 55 }
        (expect givingClass::).toEqual { a: "one", b: "two", c: ["three"] }
        done()


    it "extends a class with another one", (done) ->

      receivingClass = ->
      receivingClass:: = { a: "original", d: 55 }

      givingClass = ->
      givingClass:: = { a: "one", b: "two", c: ["three"] }

      @run (sb) ->
        sb.mixin receivingClass, givingClass
        (expect receivingClass::).toEqual { a: "original", b: "two", c: ["three"], d: 55 }
        (expect givingClass::).toEqual { a: "one", b: "two", c: ["three"] }
        done()
