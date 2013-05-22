require?("../nodeSetup")()

describe "util plugin", ->

  if typeof(require) is "function"
    scaleApp  = require "../../dist/scaleApp"
    plugin    = require "../../dist/plugins/scaleApp.util"

  else if window?
    scaleApp  = window.scaleApp
    plugin    = scaleApp.plugins.util

  before (done) ->

    @core = new scaleApp.Core
    @core.use(plugin).boot done

    # helper method
    @run = (fn, cb=->) =>

        # create module
      mod = (sb) ->
        init: -> fn sb
        destroy: ->

      # register module
      @core.register "myId", mod

      # start that moudle
      @core.start "myId", callback: cb

  it "installs it to the core", ->

    (expect typeof @core.countObjectKeys).toEqual "function"
    (expect typeof @core.mixin).toEqual "function"
    (expect typeof @core.uniqueId).toEqual "function"
    (expect typeof @core.clone).toEqual "function"

  describe "countObjectKeys", ->

    it "works correctly", ->

      (expect @core.countObjectKeys { a:"a", b: "", c: 123 }).toEqual 3
      (expect @core.countObjectKeys [ "a", false, 123, true ]).toEqual 4

  describe "mixin", ->

    it "extends an object", ->

        receivingObject = { a: "original", d: 55 }
        givingObject = { a: "one", b: "two", c: ["three"] }
        @core.mixin receivingObject, givingObject
        (expect receivingObject).toEqual { a: "original", b: "two", c: ["three"], d: 55 }

    it "extends a class with an object", ->

      receivingClass = ->
      receivingClass:: = { a: "original", d: 55 }
      expected = { a: "original", b: "two", c: ["three"], d: 55 }
      givingObject = { a: "one", b: "two", c: ["three"] }

      @core.mixin receivingClass, givingObject
      (expect receivingClass:: ).toEqual expected
      (expect givingObject ).toEqual { a: "one", b: "two", c: ["three"] }

    it "extends an object with a class", ->

      receivingObject = { a: "original", d: 55 }
      givingClass = ->
      givingClass:: = { a: "one", b: "two", c: ["three"] }

      @core.mixin receivingObject, givingClass
      (expect receivingObject).toEqual { a: "original", b: "two", c: ["three"], d: 55 }
      (expect givingClass::).toEqual { a: "one", b: "two", c: ["three"] }

    it "extends a class with another one", ->

      receivingClass = ->
      receivingClass:: = { a: "original", d: 55 }

      givingClass = ->
      givingClass:: = { a: "one", b: "two", c: ["three"] }

      @core.mixin receivingClass, givingClass
      (expect receivingClass::).toEqual { a: "original", b: "two", c: ["three"], d: 55 }
      (expect givingClass::).toEqual { a: "one", b: "two", c: ["three"] }
