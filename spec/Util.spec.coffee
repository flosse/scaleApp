require?("./nodeSetup")()

describe "Util", ->

  before ->
    if typeof(require) is "function"
      @util = require "../src/Util"
    else if window?
      @util = window.scaleApp.util

  describe "runSeries function", ->

    it "runs an array of functions", (done) ->
      cb1 = (next) -> next null, "one"
      cb2 = (next) -> setTimeout (-> next null, "two"), 0
      cb3 = (next) -> next null, "three"

      (expect typeof @util.runSeries).toEqual "function"
      @util.runSeries [cb1, cb2, cb3], (err, res) ->
        (expect err?).toEqual false
        (expect res).toEqual ["one","two", "three"]
        done()

    it "does not break if the array is empty or not defined", (done) ->
      @util.runSeries [], (err, res) =>
        (expect err?).toBe false
        @util.runSeries undefined, (err, res) ->
          (expect err?).toBe false
          done()

    it "runs all functions even if an error occours", (done) ->
      cb1 = (next) -> next null, "one"
      cb2 = (next) -> thisMethodDoesNotExist()
      cb3 = (next) -> next null, "three"
      cb4 = (next) -> next (new Error "fake"), "four"
      @util.runSeries [cb1, cb2, cb3, cb4], (err, res) ->
        (expect err?).toEqual true
        (expect res).toEqual ["one", undefined, "three", undefined]
        done()

  describe "doForAll function", ->

    it "runs a functions for each argument within an array ", (done) ->
      result = []
      fn = (arg, next) -> result.push arg; next()

      @util.doForAll ["a", 2, false], fn, (err) ->
        (expect err?).toBe false
        (expect result).toEqual ["a", 2, false]
        done()

    it "does not break if the array is empty or not defined", (done) ->
      fn = (arg, next) -> next()
      @util.doForAll [], fn, (err) =>
        (expect err?).toBe false
        @util.doForAll undefined, fn, (err) ->
          (expect err?).toBe false
          done()

  describe "getArgumentNames function", ->

    it "returns an array of argument names", ->
      fn = (a,b,c,d) ->
      (expect @util.getArgumentNames fn).toEqual ["a","b","c", "d"]
      (expect @util.getArgumentNames ->).toEqual []

    it "does not break if the function is not defined", ->
      (expect @util.getArgumentNames undefined).toEqual []
