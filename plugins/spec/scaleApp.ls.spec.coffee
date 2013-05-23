require?("../../spec/nodeSetup")()

describe "ls plugin", ->

  if typeof(require) is "function"
    scaleApp  = require "../../dist/scaleApp"
    plugin    = require "../../dist/plugins/scaleApp.ls"

  else if window?
    scaleApp  = window.scaleApp
    plugin    = scaleApp.plugins.ls

  before ->

    @core = new scaleApp.Core
    @core.use(plugin).boot()

  it "has an lsModules method", ->
    (expect typeof @core.lsModules).toEqual "function"
    @core.register "myModule", ->
    (expect @core.lsModules()).toEqual ["myModule"]

  it "has an lsInstances method", ->
    (expect typeof @core.lsInstances).toEqual "function"
    (expect @core.lsInstances()).toEqual []
    @core.register "myModule", -> init: (->), destroy: (->)
    @core.start "myModule"
    (expect @core.lsInstances()).toEqual ["myModule"]
    @core.start "myModule", instanceId: "test"
    (expect @core.lsInstances()).toEqual ["myModule", "test"]
    @core.stop "myModule"
    (expect @core.lsInstances()).toEqual ["test"]

  it "has an lsPlugins method", ->
    (expect typeof @core.lsPlugins).toEqual "function"
    if not window? # because the scaleApp object is loaded only once
      (expect @core.lsPlugins()).toEqual []
      @core.use -> { id: "dummy" }
      (expect @core.boot().lsPlugins()).toEqual ["dummy"]
