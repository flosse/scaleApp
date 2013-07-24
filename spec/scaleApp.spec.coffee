if module?.exports?
  require?("./nodeSetup")()
else if window?
  window.expect = window.chai.expect

describe "scaleApp", ->

  before ->

    if typeof(require) is "function"
      @scaleApp = getScaleApp()
    else if window?
      @scaleApp = window.scaleApp

  it "provides the global and accessible namespace scaleApp", ->
    (expect @scaleApp).to.be.an "object"

  it "has a VERSION property", ->
    (expect @scaleApp.VERSION).to.be.a "string"

  it "has a reference to the Mediator class", ->
    (expect @scaleApp.Mediator).to.be.a "function"
