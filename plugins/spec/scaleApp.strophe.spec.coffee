require?("../../spec/nodeSetup")()

describe "xmpp plugin", ->

  before ->
    if typeof(require) is "function"
      @scaleApp  = require "../../dist/scaleApp"
      @plugin    = require "../../dist/plugins/scaleApp.xmpp"

    else if window?
      @scaleApp  = window.scaleApp
      @plugin    = @scaleApp.plugins.xmpp

    @core = new @scaleApp.Core
    @core.use(@plugin).boot()

  it "has an API", ->
    (expect @core.xmpp            ).to.be.an "object"
    (expect @core.xmpp.login      ).to.be.a "function"
    (expect @core.xmpp.logout     ).to.be.a "function"
    (expect @core.xmpp.on         ).to.be.a "function"
    (expect @core.xmpp.off        ).to.be.a "function"
    (expect @core.xmpp.connection ).to.be.null
    (expect @core.xmpp.jid        ).to.equal ""
    (expect @core.xmpp._mediator instanceof @core.Mediator ).to.equal true
