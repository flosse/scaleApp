require?("../../spec/nodeSetup")()

describe "stateMachine plugin", ->

  beforeEach ->

    if typeof(require) is "function"
      @scaleApp = require "../../dist/scaleApp"
      @plugin   = require "../../dist/plugins/scaleApp.state"

    else if window?
      @scaleApp = window.scaleApp
      @plugin   = @scaleApp.plugins.state

    @core    = (new @scaleApp.Core).use(@plugin).boot()
    @machine = new @core.StateMachine

  it "installs it to the core", ->
    (expect @core.StateMachine).to.be.a "function"

  describe "constructor", ->
    it "takes a transitions object with multiple transitions", ->
      machine = new @core.StateMachine
        states: ["a", "b", "c"]
        transitions:
          x: {from: "a", to: "b"}
          y: {from: "b", to: "c"}
      (expect machine.transitions.x).to.eql {from: "a", to: "b"}
      (expect machine.transitions.y).to.eql {from: "b", to: "c"}

    it "emits onEnter for start state", (done) ->
      onEnter = (t, channel) ->
        (expect channel).to.equal 'a/enter'
        (expect t).to.be.undefined
        done()
      machine = new @core.StateMachine
        start: 'a'
        states:
          a: {enter: onEnter}

    it "registers onLeave for start state", (done) ->
      onLeave = (t, channel) ->
        (expect channel).to.equal 'a/leave'
        (expect t).to.eql {from: "a", to: "b"}
        done()
      machine = new @core.StateMachine
        start: 'a'
        states:
          a: {leave: onLeave}
          b: {}
        transitions:
          x: {from: "a", to: "b"}
      machine.fire 'x'

  describe "addState method", ->

    it "takes a state id", ->
      (expect @machine.addState).to.be.a "function"
      (expect @machine.addState "state").to.be.true

    it "returns false if the state is not a string", ->
      (expect @machine.addState 5).to.be.false

    it "returns false if the state already exists", ->
      (expect @machine.addState "state").to.be.true
      (expect @machine.addState "state").to.be.false

    it "takes an second parameter that holds callback functions", ->
      (expect @machine.addState "state1", {leave: (->), enter: 52  }).to.be.false
      (expect @machine.addState "state2", {leave: 43,   enter: (->)}).to.be.false
      (expect @machine.addState "state3", {leave: 43,   enter: 44  }).to.be.false
      (expect @machine.addState "state4", {leave: (->), enter: (->)}).to.be.true
      (expect @machine.addState
        state5: {leave: (->), enter: (->)}
        sate6: {leave: (->), enter: (->)}
      ).to.be.true
      (expect @machine.addState
        state5: {leave: (->), enter: (->)}
        sate6: {leave: 4, enter: (->)}
      ).to.be.false

  describe "addTransition method", ->

    it "takes a transition id and an edge definition", ->
      @machine.addState "fromState"
      @machine.addState "toState"
      (expect @machine.addTransition "t", from: "fromState", to: "toState").to.be.true

    it "returns false if one of the arguments is neither string, nor array", ->
      (expect @machine.addTransition 0,   from: "fromState", to: "toState").to.be.false
      (expect @machine.addTransition "x", from: 1,           to: "toState").to.be.false
      (expect @machine.addTransition "x", from: "y",         to:  2).to.be.false

    it "returns false if the transition already exists", ->
      @machine.addState ["a", "b", "c", "d"]
      (expect @machine.addTransition "x", from: "a", to: "b").to.be.true
      (expect @machine.addTransition "x", from: "c", to: "d").to.be.false

    it "returns false if one of the transition states don't exist", ->
      @machine.addState ["a","b"]
      (expect @machine.addTransition "x", from: "a", to: "b").to.be.true
      (expect @machine.addTransition "y", from: "c", to: "d").to.be.false

    it "can take multiple from states", ->
      @machine.addState ["a", "b", "c", "d"]
      @machine.current = "a"
      (expect @machine.addTransition "x", from: ["a", "c", "d"], to: "b").to.be.true

    it "returns false if one of the multiple from states doesn't exist", ->
      @machine.addState ["a", "b"]
      @machine.current = "a"
      (expect @machine.addTransition "x", from: ["a", "b", "c"], to: "b").to.be.false

    it "can take '*' as a from state wildcard", ->
      @machine.addState ["a", "b"]
      @machine.current = "z"
      (expect @machine.addTransition "x", from: "*", to: "a").to.be.true
      (expect @machine.can "x").to.be.true

  describe "onEnter method", ->

    it "takes a state name and a function as parameters", (done) ->
      cb = sinon.spy()
      @machine.current = "a"
      @machine.addState ["a", "b"]
      @machine.addTransition "x", { from: "a", to: "b" }
      (expect @machine.onEnter).to.be.a "function"
      (expect @machine.onEnter "b", cb).not.to.be.false
      @machine.fire "x", (err) ->
        (expect cb).to.have.been.called
        done()

  describe "onLeave method", ->

    it "takes a state name and a function as parameters", (done) ->
      cb = sinon.spy()
      @machine.current = "a"
      @machine.addState ["a", "b"]
      @machine.addTransition "x", { from: "a", to: "b" }
      expect @machine.onEnter "b", cb
      expect @machine.onLeave "a", ->
        (expect cb).not.to.have.been.called
      @machine.fire "x", ->
        (expect cb).to.have.been.called
        done()

  describe "fire method", ->

    it "fires a transition", ->
      @machine.current = "a"
      @machine.addState ["a", "b"]
      @machine.addTransition "x", from: "a", to: "b"
      (expect @machine.fire "x").to.be.true
      (expect @machine.current).to.equal "b"

    it "returns false if transition is not defined for current state", ->
      @machine.addState ["a", "b"]
      @machine.addTransition "x", from: "a", to: "b"
      (expect @machine.fire "x").to.be.false


    it "calls the callback", (done) ->
      @machine.current = "a"
      @machine.addState ["a", "b"]
      @machine.addTransition "x", from: "a", to: "b"
      @machine.fire "x", (err) =>
        (expect err).not.to.be.false
        (expect @machine.current).to.equal "b"
        done()

    it "does not change the state if something went wrong", (done) ->
      cb = sinon.spy()
      @machine.current = "a"
      @machine.addState ["a", "b"]
      @machine.addTransition "x", { from: "a", to: "b" }
      @machine.onEnter "b", cb
      @machine.onLeave "a", (data, channel, x) -> x new Error "uups"
      @machine.fire "x", (err) =>
        (expect cb.callCount).to.equal 0
        (expect err).to.exist
        (expect @machine.current).to.equal "a"
        done()

    it "emits 'leaveChannel' for current state", (done) ->
      @machine.current = "a"
      @machine.addState ["a", "b", "c"]
      @machine.addTransition "x", from: ["a", "b"], to: "c"
      @machine.onLeave "a", ->
        done()
      (expect @machine.fire "x").to.be.true

  describe "can method", ->
    it "returns true if transition can be fired", ->
      @machine.addState ["a", "b"]
      @machine.addTransition "x", from: "a", to: "b"
      @machine.current = "a"
      (expect @machine.can "x").to.be.true

    it "returns true if current state is in transition.from", ->
      @machine.addState ["a", "b", "c"]
      @machine.addTransition "x", from: ["a", "b"], to: "c"
      @machine.current = "a"
      (expect @machine.can "x").to.be.true
