scaleApp   = require("../../src/scaleApp")
plugin     = require("../../src/plugins/scaleApp.mvc").Plugin

scaleApp.registerPlugin plugin

describe "mvc plugin", ->
  
  describe "Model", ->
    beforeEach ->
      @m = new scaleApp.Model

    it "takes an object as constructor parameter", ->
      m = new scaleApp.Model { key: "value" }
      (expect m.key).toEqual "value"

    it "does not override existing keys", ->
      m = new scaleApp.Model { set: "value" }
      (expect m.set).toNotEqual "value"
      (expect typeof m.set).toEqual "function"

    it "generates an id", ->
      m = new scaleApp.Model { key: "value" }
      (expect typeof m.id).toEqual "string"

      m = new scaleApp.Model { id: "myId" }
      (expect m.id).toEqual "myId"

    it "provides a subscribe function", ->
      (expect typeof @m.subscribe).toEqual "function"

    it "modifies a new value", ->
      m = new scaleApp.Model { key: "value" }
      m.set "key", 123
      m.set "set", 123
      #test chain
      (m.set "foo", "foo")
        .set( "bar", "bar")
        .set("a","b")
      (expect m.key).toEqual 123
      (expect m.get "key").toEqual 123
      (expect m.foo).toEqual "foo"
      (expect m.bar).toEqual "bar"
      (expect m.a).toEqual "b"
      (expect m.set).toNotEqual 123

    it "modifies multiple values", ->
      m = new scaleApp.Model { key: "value" }
      m.set { key:123, foo:"bar", num: 321 }
      (expect m.key).toEqual 123
      (expect m.get "key").toEqual 123
      (expect m.foo).toEqual "bar"
      (expect m.num).toEqual 321

    it "publishes a 'changed' event", ->
      cb = jasmine.createSpy "a callback"
      m = new scaleApp.Model { key: "value" }
      m.subscribe "changed", cb
      m.set "key", 123
      (expect cb).toHaveBeenCalled()

    it "does not publishes a 'changed' event if the value is the same", ->
      cb = jasmine.createSpy "a callback"
      m = new scaleApp.Model { key: "value" }
      m.subscribe "changed", cb
      m.set "key", "value"
      (expect cb).wasNotCalled()

    it "can serialized to JSON", ->

      class M extends scaleApp.Model
        constructor: -> super { key: "value" }
        foo: ->
        bar: false

      m = new M
      j = m.toJSON()
      (expect j.key).toEqual "value"
      (expect j.foo).toBeUndefined()
      (expect j.bar).toBeUndefined()

  describe "View", ->

    beforeEach ->
      @m = new scaleApp.Model { key: "value" }
      @v = new scaleApp.View

    it "can take a model as constructor parameter", ->
      v = new scaleApp.View @m
      (expect v.model).toEqual @m
      v = new scaleApp.View
      (expect v.model).toBeUndefined()

    it "renders the view when the model state changed and the model exists", ->

      cb1 = jasmine.createSpy "first callback"
      cb2 = jasmine.createSpy "second callback"

      viewWithModel = new scaleApp.View @m
      viewWithoutModel = new scaleApp.View

      viewWithModel.render = cb1
      viewWithoutModel.render = cb2

      @m.set "key", "new value"
      (expect cb1).toHaveBeenCalled()
      (expect cb2).wasNotCalled()

      viewWithoutModel.setModel @m
      @m.set "key", "an other val"
      (expect cb2).wasCalled()


  describe "Controller", ->

    beforeEach ->
      @m = new scaleApp.Model { key: "value" }
      @v = new scaleApp.View @m

    it "holds a reference to the model and the view", ->
      c = new scaleApp.Controller @m, @v
      (expect c.model).toEqual @m
      (expect c.view).toEqual @v
