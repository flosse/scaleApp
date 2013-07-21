require?("./nodeSetup")()

describe "Util", ->

  before ->
    if typeof(require) is "function"
      @util = require("../dist/scaleApp").util
    else if window?
      @util = window.scaleApp.util

  describe "runParallel", ->

    it "runs an array of functions", (done) ->
      spy1 = sinon.spy()
      spy2 = sinon.spy()
      spy3 = sinon.spy()
      cb1 = (next) ->
        (expect spy1).not.toHaveBeenCalled()
        (expect spy2).not.toHaveBeenCalled()
        (expect spy3).not.toHaveBeenCalled()
        setTimeout (->
          (expect spy1).not.toHaveBeenCalled()
          (expect spy2).toHaveBeenCalled()
          (expect spy3).toHaveBeenCalled()
          spy1()
          next null, "one", false
        ), 30

      cb2 = (next) ->
        (expect spy1).not.toHaveBeenCalled()
        (expect spy2).not.toHaveBeenCalled()
        (expect spy3).not.toHaveBeenCalled()
        setTimeout (->
          (expect spy1).not.toHaveBeenCalled()
          (expect spy2).not.toHaveBeenCalled()
          (expect spy3).toHaveBeenCalled()
          spy2()
          next null, "two"
        ), 0

      cb3 = (next) ->
        (expect spy1).not.toHaveBeenCalled()
        (expect spy2).not.toHaveBeenCalled()
        (expect spy3).not.toHaveBeenCalled()
        spy3()
        next null, "three"

      (expect typeof @util.runParallel).toEqual "function"
      @util.runParallel [cb1, cb2, cb3], (err, res) ->
        (expect err?).toEqual false
        (expect res).toEqual [["one", false],"two", "three"]
        done()

    it "does not break if the array is empty or not defined", (done) ->
      @util.runParallel [], (err, res) =>
        (expect err?).toBe false
        @util.runParallel undefined, (err, res) ->
          (expect err?).toBe false
          done()

    it "doesn't stop on errors if the 'force' option is 'true'", (done) ->
      cb1 = (next) -> next null, "one", 2
      cb2 = (next) -> thisMethodDoesNotExist()
      cb3 = (next) -> next null, "three"
      cb4 = (next) -> next (new Error "fake"), "four"
      fini = (err, res) ->
        (expect err?).toEqual true
        (expect res[0]).toEqual ["one", 2]
        (expect res[1]).not.toBeDefined()
        (expect res[2]).toEqual "three"
        (expect res[3]).not.toBeDefined()
        done()
      @util.runParallel [cb1, cb2, cb3, cb4], fini, true

  describe "runSeries", ->
    it "runs an array of functions", (done) ->
      spy1 = sinon.spy()
      spy2 = sinon.spy()
      spy3 = sinon.spy()
      cb1 = (next) ->
        (expect spy1).not.toHaveBeenCalled()
        (expect spy2).not.toHaveBeenCalled()
        (expect spy3).not.toHaveBeenCalled()
        setTimeout (->
          (expect spy1).not.toHaveBeenCalled()
          (expect spy2).not.toHaveBeenCalled()
          (expect spy3).not.toHaveBeenCalled()
          spy1()
          next null, "one", false
        ), 30

      cb2 = (next) ->
        (expect spy1).toHaveBeenCalled()
        (expect spy2).not.toHaveBeenCalled()
        (expect spy3).not.toHaveBeenCalled()
        setTimeout (->
          (expect spy1).toHaveBeenCalled()
          (expect spy2).not.toHaveBeenCalled()
          (expect spy3).not.toHaveBeenCalled()
          spy2()
          next null, "two"
        ), 0

      cb3 = (next) ->
        (expect spy1).toHaveBeenCalled()
        (expect spy2).toHaveBeenCalled()
        (expect spy3).not.toHaveBeenCalled()
        spy3()
        next null, "three"

      (expect typeof @util.runSeries).toEqual "function"
      @util.runSeries [cb1, cb2, cb3], (err, res) ->
        (expect err?).toEqual false
        (expect res[0]).toEqual ["one", false]
        (expect res[1]).toEqual "two"
        (expect res[2]).toEqual "three"
        done()

    it "does not break if the array is empty or not defined", (done) ->
      @util.runSeries [], (err, res) =>
        (expect err?).toBe false
        @util.runSeries undefined, (err, res) ->
          (expect err?).toBe false
          done()

    it "stops on errors", (done) ->
      cb1 = (next) -> next null, "one", 2
      cb2 = (next) -> thisMethodDoesNotExist()
      cb3 = (next) -> next null, "three"
      fini = (err, res) ->
        (expect err?).toEqual true
        (expect res[0]).toEqual ["one", 2]
        (expect res[1]).not.toBeDefined()
        (expect res[2]).not.toBeDefined()
        done()
      @util.runSeries [cb1, cb2, cb3], fini

    it "doesn't stop on errors if the 'force' option is 'true'", (done) ->
      cb1 = (next) -> next null, "one", 2
      cb2 = (next) -> thisMethodDoesNotExist()
      cb3 = (next) -> next null, "three"
      cb4 = (next) -> next (new Error "fake"), "four"
      fini = (err, res) ->
        (expect err?).toEqual true
        (expect res[0]).toEqual ["one", 2]
        (expect res[1]).not.toBeDefined()
        (expect res[2]).toEqual "three"
        (expect res[3]).not.toBeDefined()
        done()
      @util.runSeries [cb1, cb2, cb3, cb4], fini, true

  describe "runWaterfall", ->

    it "runs an array of functions and passes the results", (done) ->
      cb1 = (next) -> next null, "one", 2
      cb2 = (a, b, next) ->
        (expect a).toEqual "one"
        (expect b).toEqual 2
        setTimeout (-> next null, 3), 0
      cb3 = (d, next) ->
        (expect d).toEqual 3
        next null, "finished :-)", "yeah"
      @util.runWaterfall [cb1, cb2, cb3], (err, res1, res2) ->
        (expect err?).toBe false
        (expect res1).toEqual "finished :-)"
        (expect res2).toEqual "yeah"
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
