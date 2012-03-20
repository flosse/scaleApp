scaleApp   = require("../../src/scaleApp")
utilPlugin = require("../../src/plugins/scaleApp.util").Plugin

scaleApp.registerPlugin utilPlugin

describe "util plugin", ->

  testIt = ->
  run = -> scaleApp.start "myId"

  mod = (@sb) ->
    init: =>
      testIt @sb
    destroy: ->

  beforeEach ->
    scaleApp.register "myId", mod

  afterEach ->
    scaleApp.stopAll()
    scaleApp.unregisterAll()

  it "installs it to the sandbox", ->

    cb = jasmine.createSpy "a callback"

    testIt = (sb) ->
      (expect typeof sb.countObjectKeys).toEqual "function"
      (expect typeof sb.mixin).toEqual "function"
      cb()

    run()
    (expect cb).toHaveBeenCalled()

  describe "countObjectKeys", ->

    it "works correctly", ->

      testIt = (sb) ->
        (expect sb.countObjectKeys { a:"a", b: "", c: 123 }).toEqual 3
        (expect sb.countObjectKeys [ "a", false, 123, true ]).toEqual 4

      (expect scaleApp.start "myId").toBeTruthy()

  describe "mixin", ->

    it "extends an object", ->

      testIt = (sb) ->
        receivingObject = { a: "original", d: 55 }
        givingObject = { a: "one", b: "two", c: ["three"] }
        sb.mixin receivingObject, givingObject
      run()

    it "extends a class with an object", ->

      receivingClass = ->
      receivingClass:: = { a: "original", d: 55 }
      expected = { a: "original", b: "two", c: ["three"], d: 55 }
      givingObject = { a: "one", b: "two", c: ["three"] }

      testIt = (sb) -> sb.mixin receivingClass, givingObject
      run()

      (expect receivingClass:: ).toEqual expected
      (expect givingObject ).toEqual { a: "one", b: "two", c: ["three"] }

    it "extends an object with a class", ->

      receivingObject = { a: "original", d: 55 }
      givingClass = ->
      givingClass:: = { a: "one", b: "two", c: ["three"] }

      testIt = (sb) -> sb.mixin receivingObject, givingClass
      run()

      (expect receivingObject).toEqual { a: "original", b: "two", c: ["three"], d: 55 }
      (expect givingClass::).toEqual { a: "one", b: "two", c: ["three"] }

    it "extends a class with another one", ->

      receivingClass = ->
      receivingClass:: = { a: "original", d: 55 }

      givingClass = ->
      givingClass:: = { a: "one", b: "two", c: ["three"] }

      testIt = (sb) -> sb.mixin receivingClass, givingClass
      run()

      (expect receivingClass::).toEqual { a: "original", b: "two", c: ["three"], d: 55 }
      (expect givingClass::).toEqual { a: "one", b: "two", c: ["three"] }
