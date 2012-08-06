require?("../nodeSetup")()

describe "stateMachine plugin", ->

  before ->

    if typeof(require) is "function"
      @scaleApp  = require "../../src/scaleApp"
      @scaleApp.registerPlugin require "../../src/plugins/scaleApp.state"
      @machine = new @scaleApp.StateMachine

    else if window?
      @scaleApp  = window.scaleApp

  after -> @scaleApp.unregisterAll()

  it "installs it to the core", ->
    (expect typeof @scaleApp.StateMachine).toEqual "function"

  describe "addState method", ->

    it "takes a state id", ->
      (expect typeof @machine.addState).toEqual "function"
      (expect @machine.addState "state").toBe true
      (expect "state" in @machine.states).toBe true

    it "returns false if the state is not a string", ->
      (expect @machine.addState 5).toBe false

    it "returns false if the state already exists", ->
      (expect @machine.addState "state").toBe true
      (expect @machine.addState "state").toBe false

  describe "addTransition method", ->

    it "takes a transition id and an edge definition", ->
      @machine.addState "fromState"
      @machine.addState "toState"
      (expect @machine.addTransition "t", from: "fromState", to: "toState").toBe true

    it "returns false if one of the arguments is not a string", ->
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

  describe "fire method", ->

    it "fires a transition", ->
      @machine.current = "a"
      @machine.addState ["a", "b"]
      @machine.addTransition "x", from: "a", to: "b"
      (expect typeof @machine.fire).toEqual "function"
      (expect @machine.fire "x").toEqual true
      (expect @machine.current).toEqual "b"

    it "returns false if transition is not defined for current state", ->
      @machine.addState ["a", "b"]
      @machine.addTransition "x", from: "a", to: "b"
      (expect @machine.fire "x").toEqual false

  describe "can method", ->
    it "returns true if transition can be fired", ->
      @machine.addState ["a", "b"]
      @machine.addTransition "x", from: "a", to: "b"
      @machine.current = "a"
      (expect @machine.can "x").toEqual true

