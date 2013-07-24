require?("../../spec/nodeSetup")()

describe "util plugin", ->

  if typeof(require) is "function"
    scaleApp  = require "../../dist/scaleApp"
    plugin    = require "../../dist/plugins/scaleApp.util"

  else if window?
    scaleApp  = window.scaleApp
    plugin    = scaleApp.plugins.util

  beforeEach (done) ->

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

    (expect @core.countObjectKeys).to.be.a "function"
    (expect @core.mixin).to.be.a "function"
    (expect @core.uniqueId).to.be.a "function"
    (expect @core.clone).to.be.a "function"

  describe "countObjectKeys", ->

    it "works correctly", ->

      (expect @core.countObjectKeys { a:"a", b: "", c: 123 }).to.equal 3
      (expect @core.countObjectKeys [ "a", false, 123, true ]).to.equal 4

  describe "mixin", ->

    it "extends an object", ->

        receivingObject = { a: "original", d: 55 }
        givingObject = { a: "one", b: "two", c: ["three"] }
        @core.mixin receivingObject, givingObject
        (expect receivingObject).to.eql { a: "original", b: "two", c: ["three"], d: 55 }

    it "extends a class with an object", ->

      receivingClass = ->
      receivingClass:: = { a: "original", d: 55 }
      expected = { a: "original", b: "two", c: ["three"], d: 55 }
      givingObject = { a: "one", b: "two", c: ["three"] }

      @core.mixin receivingClass, givingObject
      (expect receivingClass:: ).to.eql expected
      (expect givingObject ).to.eql { a: "one", b: "two", c: ["three"] }

    it "extends an object with a class", ->

      receivingObject = { a: "original", d: 55 }
      givingClass = ->
      givingClass:: = { a: "one", b: "two", c: ["three"] }

      @core.mixin receivingObject, givingClass
      (expect receivingObject).to.eql { a: "original", b: "two", c: ["three"], d: 55 }
      (expect givingClass::).to.eql { a: "one", b: "two", c: ["three"] }

    it "extends a class with another one", ->

      receivingClass = ->
      receivingClass:: = { a: "original", d: 55 }

      givingClass = ->
      givingClass:: = { a: "one", b: "two", c: ["three"] }

      @core.mixin receivingClass, givingClass
      (expect receivingClass::).to.eql { a: "original", b: "two", c: ["three"], d: 55 }
      (expect givingClass::).to.eql { a: "one", b: "two", c: ["three"] }
