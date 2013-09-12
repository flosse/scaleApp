if module?.exports?
  require?("./nodeSetup")()
else if window?
  window.expect = window.chai.expect

describe "Util", ->

  beforeEach ->
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
        (expect spy1).not.to.have.been.called
        (expect spy2).not.to.have.been.called
        (expect spy3).not.to.have.been.called
        setTimeout (->
          (expect spy1).not.to.have.been.called
          (expect spy2).to.have.been.called
          (expect spy3).to.have.been.called
          spy1()
          next null, "one", false
        ), 30

      cb2 = (next) ->
        (expect spy1).not.to.have.been.called
        (expect spy2).not.to.have.been.called
        (expect spy3).not.to.have.been.called
        setTimeout (->
          (expect spy1).not.to.have.been.called
          (expect spy2).not.to.have.been.called
          (expect spy3).to.have.been.called
          spy2()
          next null, "two"
        ), 0

      cb3 = (next) ->
        (expect spy1).not.to.have.been.called
        (expect spy2).not.to.have.been.called
        (expect spy3).not.to.have.been.called
        spy3()
        next null, "three"

      (expect @util.runParallel).to.be.a "function"
      @util.runParallel [cb1, cb2, cb3], (err, res) ->
        (expect err).not.to.exist
        (expect res).to.deep.equal [["one", false],"two", "three"]
        done()

    it "does not break if the array is empty or not defined", (done) ->
      @util.runParallel [], (err, res) =>
        (expect err?).to.be.false
        @util.runParallel undefined, (err, res) ->
          (expect err?).to.be.false
          done()

    it "doesn't stop on errors if the 'force' option is 'true'", (done) ->
      cb1 = (next) -> next null, "one", 2
      cb2 = (next) -> thisMethodDoesNotExist()
      cb3 = (next) -> next null, "three"
      cb4 = (next) -> next (new Error "fake"), "four"
      fini = (err, res) ->
        (expect err).to.exist
        (expect res[0]).to.eql ["one", 2]
        (expect res[1]).not.to.exist
        (expect res[2]).to.equal "three"
        (expect res[3]).not.to.exist
        done()
      @util.runParallel [cb1, cb2, cb3, cb4], fini, true

  describe "runSeries", ->
    it "runs an array of functions", (done) ->
      spy1 = sinon.spy()
      spy2 = sinon.spy()
      spy3 = sinon.spy()
      cb1 = (next) ->
        (expect spy1).not.to.have.been.called
        (expect spy2).not.to.have.been.called
        (expect spy3).not.to.have.been.called
        setTimeout (->
          (expect spy1).not.to.have.been.called
          (expect spy2).not.to.have.been.called
          (expect spy3).not.to.have.been.called
          spy1()
          next null, "one", false
        ), 30

      cb2 = (next) ->
        (expect spy1).to.have.been.called
        (expect spy2).not.to.have.been.called
        (expect spy3).not.to.have.been.called
        setTimeout (->
          (expect spy1).to.have.been.called
          (expect spy2).not.to.have.been.called
          (expect spy3).not.to.have.been.called
          spy2()
          next null, "two"
        ), 0

      cb3 = (next) ->
        (expect spy1).to.have.been.called
        (expect spy2).to.have.been.called
        (expect spy3).not.to.have.been.called
        spy3()
        next null, "three"

      (expect @util.runSeries).to.be.a "function"
      @util.runSeries [cb1, cb2, cb3], (err, res) ->
        (expect err).not.to.exist
        (expect res.hasOwnProperty '-1').to.equal false
        (expect res[0]).to.eql ["one", false]
        (expect res[1]).to.equal "two"
        (expect res[2]).to.equal "three"
        done()

    it "does not break if the array is empty or not defined", (done) ->
      @util.runSeries [], (err, res) =>
        (expect err).not.to.exist
        @util.runSeries undefined, (err, res) ->
          (expect err).not.to.exist
          done()

    it "stops on errors", (done) ->
      cb1 = (next) -> next null, "one", 2
      cb2 = (next) -> thisMethodDoesNotExist()
      cb3 = (next) -> next null, "three"
      fini = (err, res) ->
        (expect err).to.exsit
        (expect res[0]).to.eql ["one", 2]
        (expect res[1]).not.to.exist
        (expect res[2]).not.to.exist
        done()
      @util.runSeries [cb1, cb2, cb3], fini

    it "doesn't stop on errors if the 'force' option is 'true'", (done) ->
      cb1 = (next) -> next null, "one", 2
      cb2 = (next) -> thisMethodDoesNotExist()
      cb3 = (next) -> next null, "three"
      cb4 = (next) -> next (new Error "fake"), "four"
      fini = (err, res) ->
        (expect err).to.exist
        (expect res[0]).to.eql ["one", 2]
        (expect res[1]).not.to.exist
        (expect res[2]).to.equal "three"
        (expect res[3]).not.to.exist
        done()
      @util.runSeries [cb1, cb2, cb3, cb4], fini, true

  describe "runWaterfall", ->

    it "runs an array of functions and passes the results", (done) ->
      cb1 = (next) -> next null, "one", 2
      cb2 = (a, b, next) ->
        (expect a).to.equal "one"
        (expect b).to.equal 2
        setTimeout (-> next null, 3), 0
      cb3 = (d, next) ->
        (expect d).to.equal 3
        next null, "finished :-)", "yeah"
      @util.runWaterfall [cb1, cb2, cb3], (err, res1, res2) ->
        (expect err).not.to.exist
        (expect res1).to.equal "finished :-)"
        (expect res2).to.equal "yeah"
        done()

  describe "doForAll function", ->

    it "runs a functions for each argument within an array ", (done) ->
      result = []
      fn = (arg, next) -> result.push arg; next()

      @util.doForAll ["a", 2, false], fn, (err) ->
        (expect err).not.to.exist
        (expect result).to.eql ["a", 2, false]
        done()

    it "does not break if the array is empty or not defined", (done) ->
      fn = (arg, next) -> next()
      @util.doForAll [], fn, (err) =>
        (expect err).not.to.exist
        @util.doForAll undefined, fn, (err) ->
          (expect err).not.to.exist
          done()

  describe "getArgumentNames function", ->

    it "returns an array of argument names", ->
      fn = (a,b,c,d) ->
      (expect @util.getArgumentNames fn).to.eql ["a","b","c", "d"]
      (expect @util.getArgumentNames ->).to.eql []

    it "does not break if the function is not defined", ->
      (expect @util.getArgumentNames undefined).to.eql []
