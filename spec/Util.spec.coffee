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

    it "runs all functions even if an error occours", (done) ->
      cb1 = (next) -> next null, "one"
      cb2 = (next) -> thisMethodDoesNotExist()
      cb3 = (next) -> next null, "three"
      cb4 = (next) -> next (new Error "fake"), "four"
      @util.runSeries [cb1, cb2, cb3, cb4], (err, res) ->
        (expect err?).toEqual true
        (expect res).toEqual ["one", undefined, "three", undefined]
        done()
