require?("../../spec/nodeSetup")()

describe "ls plugin", ->

  if typeof(require) is "function"
    scaleApp  = require "../../dist/scaleApp"
    plugin    = require "../../dist/plugins/scaleApp.ls"

  else if window?
    scaleApp  = window.scaleApp
    plugin    = scaleApp.plugins.ls

  beforeEach ->

    @core = new scaleApp.Core
    @core.use(plugin).boot()

  it "has an lsModules method", ->
    (expect @core.lsModules).to.be.a "function"
    @core.register "myModule", ->
    (expect @core.lsModules()).to.eql ["myModule"]

  it "has an lsInstances method", ->
    (expect @core.lsInstances).to.be.a "function"
    (expect @core.lsInstances()).to.eql []
    @core.register "myModule", -> init: (->), destroy: (->)
    @core.start "myModule"
    (expect @core.lsInstances()).to.eql ["myModule"]
    @core.start "myModule", instanceId: "test"
    (expect @core.lsInstances()).to.eql ["myModule", "test"]
    @core.stop "myModule"
    (expect @core.lsInstances()).to.eql ["test"]

  it "has an lsPlugins method", ->
    (expect @core.lsPlugins).to.be.a "function"
    if not window? # because the scaleApp object is loaded only once
      (expect @core.lsPlugins()).to.eql []
      @core.use -> { id: "dummy" }
      (expect @core.boot().lsPlugins()).to.eql ["dummy"]
