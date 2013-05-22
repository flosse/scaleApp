require?("../nodeSetup")()

describe "mvc plugin", ->
  
  before ->
    if typeof(require) is "function"
      @scaleApp  = require "../../dist/scaleApp"
      @plugin    = require "../../dist/plugins/scaleApp.mvc"

    else if window?
      @scaleApp  = window.scaleApp
      @plugin    = @scaleApp.plugins.mvc

    @core = new @scaleApp.Core
    @core.use(@plugin).boot()

  describe "Model", ->

    before -> @m = new @core.Model

    it "takes an object as constructor parameter", ->
      @m = new @core.Model { key: "value" }
      (expect @m.key).toEqual "value"

    it "does not override existing keys", ->
      @m = new @core.Model { set: "value" }
      (expect @m.set).not.toEqual "value"
      (expect typeof @m.set).toEqual "function"

    it "provides a on function", ->
      (expect typeof @m.on).toEqual "function"

    it "modifies a new value", ->
      @m = new @core.Model { key: "value" }
      @m.set "key", 123
      @m.set "set", 123
      #test chain
      (@m.set "foo", "foo")
        .set( "bar", "bar")
        .set("a","b")
      (expect @m.key).toEqual 123
      (expect @m.get "key").toEqual 123
      (expect @m.foo).toEqual "foo"
      (expect @m.bar).toEqual "bar"
      (expect @m.a).toEqual "b"
      (expect @m.set).not.toEqual 123

    it "modifies multiple values", ->
      @m = new @core.Model { key: "value" }
      @m.set { key:123, foo:"bar", num: 321 }
      (expect @m.key).toEqual 123
      (expect @m.get "key").toEqual 123
      (expect @m.foo).toEqual "bar"
      (expect @m.num).toEqual 321

    it "publishes a 'changed' event", ->
      cb = sinon.spy()
      @m = new @core.Model { key: "value" }
      @m.on "changed", cb
      @m.set "key", 123
      (expect cb).toHaveBeenCalled()

    it "does not publishes a 'changed' event if the value is the same", ->
      cb = sinon.spy()
      @m = new @core.Model { key: "value" }
      @m.on "changed", cb
      @m.set "key", "value"
      (expect cb).not.toHaveBeenCalled()

    it "can serialized to JSON", ->

      class M extends @core.Model
        constructor: -> super { key: "value" }
        foo: ->
        bar: false

      @m = new M
      j = @m.toJSON()
      (expect j.key).toEqual "value"
      (expect j.foo).not.toBeDefined()
      (expect j.bar).not.toBeDefined()

  describe "View", ->

    beforeEach ->
      @m = new @core.Model { key: "value" }
      @v = new @core.View

    it "can take a model as constructor parameter", ->
      v = new @core.View @m
      (expect v.model).toEqual @m
      v = new @core.View
      (expect v.model).not.toBeDefined()

    it "renders the view when the model state changed and the model exists", ->

      cb1 = sinon.spy()
      cb2 = sinon.spy()

      viewWithModel = new @core.View @m
      viewWithoutModel = new @core.View

      viewWithModel.render = cb1
      viewWithoutModel.render = cb2

      @m.set "key", "new value"
      (expect cb1).toHaveBeenCalled()
      (expect cb2).not.toHaveBeenCalled()

      viewWithoutModel.setModel @m
      @m.set "key", "an other val"
      (expect cb2).toHaveBeenCalled()


  describe "Controller", ->

    beforeEach ->
      @m = new @core.Model { key: "value" }
      @v = new @core.View @m

    it "holds a reference to the model and the view", ->
      c = new @core.Controller @m, @v
      (expect c.model).toEqual @m
      (expect c.view).toEqual @v
