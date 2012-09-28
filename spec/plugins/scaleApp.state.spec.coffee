require?("../nodeSetup")()

describe "stateMachine plugin", ->

  before ->

    if typeof(require) is "function"
      @scaleApp = require "../../src/scaleApp"
      @scaleApp.registerPlugin require "../../src/plugins/scaleApp.state"

    else if window?
      @scaleApp = window.scaleApp

    @machine = new @scaleApp.StateMachine

  after -> @scaleApp.unregisterAll()

  it "installs it to the core", ->
    (expect typeof @scaleApp.StateMachine).toEqual "function"

  describe "constructor", ->
    it "takes a transitions object with multiple transitions", ->
      machine = new @scaleApp.StateMachine
        states: ["a", "b", "c"]
        transitions:
          x: {from: "a", to: "b"}
          y: {from: "b", to: "c"}
      (expect machine.transitions.x).toEqual {from: "a", to: "b"}
      (expect machine.transitions.y).toEqual {from: "b", to: "c"}

    it "emits onEnter for start state", (done) ->
      onEnter = (t, channel) ->
        (expect channel).toBe 'a/enter'
        (expect t).toBe undefined
        done()
      machine = new @scaleApp.StateMachine
        start: 'a'
        states:
          a: {enter: onEnter}

    it "registers onLeave for start state", (done) ->
      onLeave = (t, channel) ->
        (expect channel).toBe 'a/leave'
        (expect t).toEqual {from: "a", to: "b"}
        done()
      machine = new @scaleApp.StateMachine
        start: 'a'
        states:
          a: {leave: onLeave}
          b: {}
        transitions:
          x: {from: "a", to: "b"}
      machine.fire 'x'

  describe "addState method", ->

    it "takes a state id", ->
      (expect typeof @machine.addState).toEqual "function"
      (expect @machine.addState "state").toBe true

    it "returns false if the state is not a string", ->
      (expect @machine.addState 5).toBe false

    it "returns false if the state already exists", ->
      (expect @machine.addState "state").toBe true
      (expect @machine.addState "state").toBe false

    it "takes an second parameter that holds callback functions", ->
      (expect @machine.addState "state1", {leave: (->), enter: 52  }).toBe false
      (expect @machine.addState "state2", {leave: 43,   enter: (->)}).toBe false
      (expect @machine.addState "state3", {leave: 43,   enter: 44  }).toBe false
      (expect @machine.addState "state4", {leave: (->), enter: (->)}).toBe true
      (expect @machine.addState
        state5: {leave: (->), enter: (->)}
        sate6: {leave: (->), enter: (->)}
      ).toBe true
      (expect @machine.addState
        state5: {leave: (->), enter: (->)}
        sate6: {leave: 4, enter: (->)}
      ).toBe false

  describe "addTransition method", ->

    it "takes a transition id and an edge definition", ->
      @machine.addState "fromState"
      @machine.addState "toState"
      (expect @machine.addTransition "t", from: "fromState", to: "toState").toBe true

    it "returns false if one of the arguments is neither string, nor array", ->
      (expect @machine.addTransition 0,   from: "fromState", to: "toState").toBe false
      (expect @machine.addTransition "x", from: 1,           to: "toState").toBe false
      (expect @machine.addTransition "x", from: "y",         to:  2).toBe false

    it "returns false if the transition already exists", ->
      @machine.addState ["a", "b", "c", "d"]
      (expect @machine.addTransition "x", from: "a", to: "b").toBe true
      (expect @machine.addTransition "x", from: "c", to: "d").toBe false

    it "returns false if one of the transition states don't exist", ->
      @machine.addState ["a","b"]
      (expect @machine.addTransition "x", from: "a", to: "b").toBe true
      (expect @machine.addTransition "y", from: "c", to: "d").toBe false

    it "can take multiple from states", ->
      @machine.addState ["a", "b", "c", "d"]
      @machine.current = "a"
      (expect @machine.addTransition "x", from: ["a", "c", "d"], to: "b").toBe true

    it "returns false if one of the multiple from states doesn't exist", ->
      @machine.addState ["a", "b"]
      @machine.current = "a"
      (expect @machine.addTransition "x", from: ["a", "b", "c"], to: "b").toBe false

    it "can take '*' as a from state wildcard", ->
      @machine.addState ["a", "b"]
      @machine.current = "z"
      (expect @machine.addTransition "x", from: "*", to: "a").toBe true
      (expect @machine.can "x").toBe true

  describe "onEnter method", ->

    it "takes a state name and a function as parameters", (done) ->
      cb = sinon.spy()
      @machine.current = "a"
      @machine.addState ["a", "b"]
      @machine.addTransition "x", { from: "a", to: "b" }
      (expect typeof @machine.onEnter).toEqual "function"
      (expect @machine.onEnter "b", cb).not.toBe false
      @machine.fire "x", (err) ->
        (expect cb).toHaveBeenCalled()
        done()

  describe "onLeave method", ->

    it "takes a state name and a function as parameters", (done) ->
      cb = sinon.spy()
      @machine.current = "a"
      @machine.addState ["a", "b"]
      @machine.addTransition "x", { from: "a", to: "b" }
      expect @machine.onEnter "b", cb
      expect @machine.onLeave "a", ->
        (expect cb).not.toHaveBeenCalled()
      @machine.fire "x", ->
        (expect cb).toHaveBeenCalled()
        done()

  describe "fire method", ->

    it "fires a transition", ->
      @machine.current = "a"
      @machine.addState ["a", "b"]
      @machine.addTransition "x", from: "a", to: "b"
      (expect @machine.fire "x").toEqual true
      (expect @machine.current).toEqual "b"

    it "returns false if transition is not defined for current state", ->
      @machine.addState ["a", "b"]
      @machine.addTransition "x", from: "a", to: "b"
      (expect @machine.fire "x").toEqual false


    it "calls the callback", (done) ->
      @machine.current = "a"
      @machine.addState ["a", "b"]
      @machine.addTransition "x", from: "a", to: "b"
      @machine.fire "x", (err) =>
        (expect err).not.toBe false
        (expect @machine.current).toBe "b"
        done()

    it "does not change the state if something went wrong", (done) ->
      cb = sinon.spy()
      @machine.current = "a"
      @machine.addState ["a", "b"]
      @machine.addTransition "x", { from: "a", to: "b" }
      @machine.onEnter "b", cb
      @machine.onLeave "a", (data, channel, x) -> x new Error "uups"
      @machine.fire "x", (err) =>
        (expect cb.callCount).toEqual 0
        (expect err?).toEqual true
        (expect @machine.current).toEqual "a"
        done()

    it "emits 'leaveChannel' for current state", (done) ->
      @machine.current = "a"
      @machine.addState ["a", "b", "c"]
      @machine.addTransition "x", from: ["a", "b"], to: "c"
      @machine.onLeave "a", ->
        done()
      (expect @machine.fire "x").toEqual true

  describe "can method", ->
    it "returns true if transition can be fired", ->
      @machine.addState ["a", "b"]
      @machine.addTransition "x", from: "a", to: "b"
      @machine.current = "a"
      (expect @machine.can "x").toEqual true

    it "returns true if current state is in transition.from", ->
      @machine.addState ["a", "b", "c"]
      @machine.addTransition "x", from: ["a", "b"], to: "c"
      @machine.current = "a"
      (expect @machine.can "x").toEqual true
