require?("./nodeSetup")()

describe "scaleApp", ->

  before ->

    if typeof(require) is "function"
      @scaleApp = getScaleApp()
    else if window?
      @scaleApp = window.scaleApp

  it "provides the global and accessible namespace scaleApp", ->
    (expect typeof @scaleApp).toEqual "object"

  it "has a VERSION property", ->
    (expect typeof @scaleApp.VERSION).toEqual "string"

  it "has a reference to the Mediator class", ->
    (expect typeof @scaleApp.Mediator).toEqual "function"
