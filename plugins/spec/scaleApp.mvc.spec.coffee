require?("../../spec/nodeSetup")()

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
      (expect @m.key).to.equal "value"

    it "does not override existing keys", ->
      @m = new @core.Model { set: "value" }
      (expect @m.set).not.to.equal "value"
      (expect @m.set).to.be.a "function"

    it "provides a on function", ->
      (expect @m.on).to.be.a "function"

    it "modifies a new value", ->
      @m = new @core.Model { key: "value" }
      @m.set "key", 123
      @m.set "set", 123
      #test chain
      (@m.set "foo", "foo")
        .set( "bar", "bar")
        .set("a","b")
      (expect @m.key).to.equal 123
      (expect @m.get "key").to.equal 123
      (expect @m.foo).to.equal "foo"
      (expect @m.bar).to.equal "bar"
      (expect @m.a).to.equal "b"
      (expect @m.set).not.to.equal 123

    it "modifies multiple values", ->
      @m = new @core.Model { key: "value" }
      @m.set { key:123, foo:"bar", num: 321 }
      (expect @m.key).to.equal 123
      (expect @m.get "key").to.equal 123
      (expect @m.foo).to.equal "bar"
      (expect @m.num).to.equal 321

    it "publishes a 'changed' event", ->
      cb = sinon.spy()
      @m = new @core.Model { key: "value" }
      @m.on "changed", cb
      @m.set "key", 123
      (expect cb).to.have.been.called

    it "does not publishes a 'changed' event if the value is the same", ->
      cb = sinon.spy()
      @m = new @core.Model { key: "value" }
      @m.on "changed", cb
      @m.set "key", "value"
      (expect cb).not.to.have.been.called

    it "can serialized to JSON", ->

      class M extends @core.Model
        constructor: -> super { key: "value" }
        foo: ->
        bar: false

      @m = new M
      j = @m.toJSON()
      (expect j.key).to.equal "value"
      (expect j.foo).not.to.exist
      (expect j.bar).not.to.exist

  describe "View", ->

    beforeEach ->
      @m = new @core.Model { key: "value" }
      @v = new @core.View

    it "can take a model as constructor parameter", ->
      v = new @core.View @m
      (expect v.model).to.equal @m
      v = new @core.View
      (expect v.model).not.to.exist

    it "renders the view when the model state changed and the model exists", ->

      cb1 = sinon.spy()
      cb2 = sinon.spy()

      viewWithModel = new @core.View @m
      viewWithoutModel = new @core.View

      viewWithModel.render = cb1
      viewWithoutModel.render = cb2

      @m.set "key", "new value"
      (expect cb1).to.have.been.called
      (expect cb2).not.to.have.been.called

      viewWithoutModel.setModel @m
      @m.set "key", "an other val"
      (expect cb2).to.have.been.called


  describe "Controller", ->

    beforeEach ->
      @m = new @core.Model { key: "value" }
      @v = new @core.View @m

    it "holds a reference to the model and the view", ->
      c = new @core.Controller @m, @v
      (expect c.model).to.equal @m
      (expect c.view).to.equal @v
