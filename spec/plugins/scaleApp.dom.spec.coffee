fs        = require 'fs'
jsdom     = require 'jsdom'
coffee    = require 'coffee-script'

scaleAppSource  =  fs.readFileSync "./src/Mediator.coffee"
scaleAppSource  += "\n" + fs.readFileSync "./src/Sandbox.coffee"
scaleAppSource  += "\n" + fs.readFileSync "./src/scaleApp.coffee"
scaleAppSource  = coffee.compile scaleAppSource
pluginSource    = fs.readFileSync "./src/plugins/scaleApp.dom.coffee"
pluginSource    = coffee.compile pluginSource + "\n"

describe "dom simulation", ->

  it "loads the dom", ->

    window   = null
    scaleApp = null

    jsdom.env
      html: '<html><body></body></html>'
      src: [ scaleAppSource, pluginSource ]
      done: (errors, w) ->
        scaleApp = w.scaleApp
        window = w

    waitsFor -> !!window

    runs -> (expect window.scaleApp).toBeDefined()

    describe "dom plugin", ->
    
      testIt = ->
      dummy = { a: "dummy" }
      run = -> scaleApp.start "myId"
    
      mod = (@sb) ->
        init: =>
          testIt @sb
        destroy: ->
    
      beforeEach ->
        scaleApp.register "myId", mod
    
      afterEach ->
        scaleApp.stopAll()
        scaleApp.unregisterAll()
    
      it "installs itself to the sandbox", ->
    
        cb = jasmine.createSpy "a callback"
    
        testIt = (sb) ->
          (expect typeof sb.getContainer).toEqual "function"
          cb()
    
        run()
        (expect cb).toHaveBeenCalled()
    
      it "returns the object that was defined in the option object", ->
        testIt = (sb) ->
          (expect sb.getContainer()).toEqual dummy
        scaleApp.start "myId", { options: { container: dummy } }
    
      it "returns the dom object which id was defined in the option object", ->
    
        cb = jasmine.createSpy "a callback"
    
        div = window.document.createElement "div"
        div.setAttribute "id", "dummy"
        window.document.body.appendChild div
    
        testIt = (sb) ->
          (expect sb.getContainer()).toEqual div
          cb()
        scaleApp.start "myId", { options: { container: "dummy" } }
        (expect cb).toHaveBeenCalled()
