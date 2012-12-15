require?("./nodeSetup")()

describe "scaleApp core", ->

  pause = (ms) ->
    ms += (new Date).getTime()
    continue while ms > new Date()

  before ->

    if typeof(require) is "function"
      @scaleApp = getScaleApp()
    else if window?
      @scaleApp = window.scaleApp
    @core = new @scaleApp.Core

    @validModule = (sb) ->
      init: (opt, done) -> setTimeout (-> done()), 0
      destroy: (done) -> setTimeout (-> done()), 0

  it "provides the global and accessible namespace scaleApp", ->
    (expect typeof @scaleApp).toEqual "object"

  it "has a VERSION property", ->
    (expect typeof @scaleApp.VERSION).toEqual "string"

  describe "register function", ->

    it "is an accessible function", ->
      (expect typeof @core).toEqual "object"

    it "returns true if the module is valid", ->
      (expect @core.register "myModule", @validModule).toBeTruthy()

    it "returns false if the module creator is an object", ->
      (expect @core.register "myObjectModule", {}).toBeFalsy()

    it "returns false if the module creator does not return an object", ->
      (expect @core.register "myModuleIsInvalid", -> "I'm not an object").toBeFalsy()

    it "returns false if the created module object has not the functions init and destroy", ->
      (expect @core.register "myModuleOtherInvalid", ->).toBeFalsy()

    it "returns true if option parameter is an object", ->
      (expect @core.register "moduleWithOpt", @validModule, { } ).toBeTruthy()

    it "returns false if the option parameter is not an object", ->
      (expect @core.register "myModuleWithWrongObj", @validModule, "I'm not an object" ).toBeFalsy()

    it "returns false if module already exits", ->
      (expect @core.register "myDoubleModule", @validModule).toBeTruthy()
      (expect @core.register "myDoubleModule", @validModule).toBeFalsy()

  describe "list methods", ->

    before ->
      @core.stopAll()
      @core.register "myModule", @validModule

    it "has an lsModules method", ->
      (expect typeof @core.lsModules).toEqual "function"
      (expect @core.lsModules()).toEqual ["myModule"]

    it "has an lsInstances method", ->
      (expect typeof @core.lsInstances).toEqual "function"
      (expect @core.lsInstances()).toEqual []
      (expect @core.start "myModule" ).toBeTruthy()
      (expect @core.lsInstances()).toEqual ["myModule"]
      (expect @core.start "myModule", instanceId: "test" ).toBeTruthy()
      (expect @core.lsInstances()).toEqual ["myModule", "test"]
      (expect @core.stop "myModule").toBeTruthy()
      (expect @core.lsInstances()).toEqual ["test"]

    it "has an plugin.ls method", ->
      (expect typeof @scaleApp.plugin.ls).toEqual "function"
      (expect @scaleApp.plugin.ls()).toEqual []
      (expect @scaleApp.plugin.register {
        id: "dummy"
      }).toBeTruthy()
      (expect @scaleApp.plugin.ls()).toEqual ["dummy"]

  describe "unregister function", ->

    it "returns true if the module was successfully removed", ->
      (expect @core.register "m", @validModule).toBeTruthy()
      (expect @core.unregister "m").toBeTruthy()
      (expect @core.start "m").toBeFalsy()

  describe "unregisterAll function", ->

    it "removes all modules", ->
      (expect @core.register "a", @validModule).toBeTruthy()
      (expect @core.register "b", @validModule).toBeTruthy()
      @core.unregisterAll()
      (expect @core.start "a").toBeFalsy()
      (expect @core.start "b").toBeFalsy()

  describe "start function", ->

    before ->
      @core.stopAll()
      @core.unregisterAll()
      @core.register "myId", @validModule

    it "is an accessible function", ->
      (expect typeof @core.start).toEqual "function"

    describe "start parameters", ->

      it "returns false if first parameter is not a string or an object", ->
        (expect @core.start 123).toBeFalsy()
        (expect @core.start ->).toBeFalsy()
        (expect @core.start []).toBeFalsy()

      it "returns true if first parameter is a string", ->
        (expect @core.start "myId").toBeTruthy()

      it "returns true if second parameter is a an object", ->
        (expect @core.start "myId", {}).toBeTruthy()

      it "returns false if second parameter is a number", ->
        (expect @core.start "myId", 123).toBeFalsy()

      it "returns false if module does not exist", ->
        (expect @core.start "foo").toBeFalsy()

      it "returns true if module exist", ->
        (expect @core.start "myId").toBeTruthy()

      it "returns false if instance was aleready started", ->
        @core.start "myId"
        (expect @core.start "myId").toBeFalsy()

      it "passes the options", (done) ->
        mod = (sb) ->
          init: (opt) ->
            (expect typeof opt).toEqual "object"
            (expect opt.foo).toEqual "bar"
            done()
          destroy: ->
        @core.register "foo", mod
        @core.start "foo", options: {foo: "bar"}

      it "calls the callback function after the initialization", (done) ->

        x     = 0
        cb    = -> (expect x).toBe(2); done()

        @core.register "anId", (sb) ->
          init: (opt, fini) ->
            setTimeout (-> x = 2; fini()), 0
            x = 1
          destroy: ->

        @core.start "anId", { callback: cb }

      it "calls the callback immediately if no callback was defined", ->
        cb = sinon.spy()
        mod1 = (sb) ->
          init: (opt) ->
          destroy: ->
        (expect @core.register "anId", mod1).toBeTruthy()
        @core.start "anId", { callback: cb }
        (expect cb).toHaveBeenCalled()

      it "calls the callback function with an error if an error occours", (done) ->
        initCB = sinon.spy()
        mod1 = (sb) ->
          init: ->
            initCB()
            thisWillProcuceAnError()
          destroy: ->
        (expect @core.register "anId", mod1).toBeTruthy()
        (expect @core.start "anId", { callback: (err)->
          (expect initCB).toHaveBeenCalled()
          (expect err.message).toEqual "could not start module: thisWillProcuceAnError is not defined"
          done()
        }).toBeFalsy()

      it "starts a separate instance", ->

        initCB = sinon.spy()
        mod1 = (sb) ->
          init: -> initCB()
          destroy: ->

        (expect @core.register "separate", mod1).toBeTruthy()
        @core.start "separate", { instanceId: "instance" }
        (expect initCB).toHaveBeenCalled()

  describe "startAll function", ->

    before ->
      @core.stopAll()
      @core.unregisterAll()

    it "is an accessible function", ->
      (expect typeof @core.startAll).toEqual "function"

    it "instantiates and starts all available modules", ->

      cb1 = sinon.spy()
      cb2 = sinon.spy()

      mod1 = (sb) ->
        init: -> cb1()
        destroy: ->

      mod2 = (sb) ->
        init: -> cb2()
        destroy: ->

      (expect @core.register "first", mod1 ).toBeTruthy()
      (expect @core.register "second", mod2).toBeTruthy()

      (expect cb1).not.toHaveBeenCalled()
      (expect cb2).not.toHaveBeenCalled()

      (expect @core.startAll()).toBeTruthy()
      (expect cb1).toHaveBeenCalled()
      (expect cb2).toHaveBeenCalled()

    it "starts all modules of the passed array", ->

      cb1 = sinon.spy()
      cb2 = sinon.spy()
      cb3 = sinon.spy()

      mod1 = (sb) ->
        init: -> cb1()
        destroy: ->

      mod2 = (sb) ->
        init: -> cb2()
        destroy: ->

      mod3 = (sb) ->
        init: -> cb3()
        destroy: ->

      @core.stopAll()
      @core.unregisterAll()

      (expect @core.register "first", mod1 ).toBeTruthy()
      (expect @core.register "second",mod2 ).toBeTruthy()
      (expect @core.register "third", mod3 ).toBeTruthy()

      (expect cb1).not.toHaveBeenCalled()
      (expect cb2).not.toHaveBeenCalled()
      (expect cb3).not.toHaveBeenCalled()

      (expect @core.startAll ["first","third"]).toBeTruthy()
      (expect cb1).toHaveBeenCalled()
      (expect cb2).not.toHaveBeenCalled()
      (expect cb3).toHaveBeenCalled()

    it "calls the callback function after all modules have started", (done) ->

      cb1 = sinon.spy()

      sync = (sb) ->
        init: (opt)->
          (expect cb1).not.toHaveBeenCalled()
          cb1()
        destroy: ->

      pseudoAsync = (sb) ->
        init: (opt, done)->
          (expect cb1.callCount).toEqual 1
          cb1()
          done()
        destroy: ->

      async = (sb) ->
        init: (opt, done)->
          setTimeout (->
            (expect cb1.callCount).toEqual 2
            cb1()
            done()
          ), 0
        destroy: ->

      @core.register "first", sync
      @core.register "second", async
      @core.register "third", pseudoAsync

      (expect @core.startAll ->
        (expect cb1.callCount).toEqual 3
        done()
      ).toBeTruthy()

    it "calls the callback after defined modules have started", (done) ->

      finished = sinon.spy()

      cb1 = sinon.spy()
      cb2 = sinon.spy()

      mod1 = (sb) ->
        init: (opt, done)->
          setTimeout (->done()), 0
          (expect finished).not.toHaveBeenCalled()
        destroy: ->

      mod2 = (sb) ->
        init: (opt, done) ->
          setTimeout (-> done()), 0
          (expect finished).not.toHaveBeenCalled()
        destroy: ->

      @core.register "first", mod1, { callback: cb1 }
      @core.register "second", mod2, { callback: cb2 }

      (expect @core.startAll ["first","second"], ->
        finished()
        (expect cb1).toHaveBeenCalled()
        (expect cb2).toHaveBeenCalled()
        done()
      ).toBeTruthy()

    it "calls the callback with an error if one or more modules couldn't start", (done) ->
      spy1 = sinon.spy()
      spy2 = sinon.spy()
      mod1 = (sb) ->
        init: -> spy1(); thisIsAnInvalidMethod()
        destroy: ->
      mod2 = (sb) ->
        init: -> spy2()
        destroy: ->
      @core.register "invalid", mod1
      @core.register "valid", mod2
      @core.startAll ["invalid", "valid"], (err) ->
        (expect spy1).toHaveBeenCalled()
        (expect spy2).toHaveBeenCalled()
        (expect err.message).toEqual "errors occoured in the following modules: 'invalid'"
        done()

    it "calls the callback with an error if one or more modules don't exist", (done) ->

      spy2 = sinon.spy()
      mod = (sb) ->
        init: (opt, done)->
          spy2()
          setTimeout (-> done()), 0
        destroy: ->
      @core.register "valid", @validModule
      @core.register "x", mod
      finished = (err) ->
        (expect err.message).toEqual "these modules don't exist: 'invalid','y'"
        done()
      (expect @core.startAll ["valid","invalid", "x", "y"], finished).toBeFalsy()
      (expect spy2).toHaveBeenCalled()

    it "calls the callback without an error if module array is empty", ->
      spy = sinon.spy()
      finished = (err) ->
        (expect err).toEqual null
        spy()
      (expect @core.startAll [], finished).toBeTruthy()
      (expect spy).toHaveBeenCalled()

  describe "stop function", ->

    beforeEach ->
      @core.stopAll()
      @core.unregisterAll()

    it "is an accessible function", ->
      (expect typeof @core.stop).toEqual "function"

    it "calls the callback afterwards", (done) ->
      (expect @core.register "valid", @validModule).toBeTruthy()
      (expect @core.start "valid").toBeTruthy()
      (expect @core.stop "valid", done).toBeTruthy()

    it "supports synchronous stopping", ->
      mod = (sb) ->
        init: ->
        destroy: ->
      end = false
      (expect @core.register "mod", mod).toBeTruthy()
      (expect @core.start "mod").toBeTruthy()
      (expect @core.stop "mod", -> end = true).toBeTruthy()
      (expect end).toEqual true

  describe "stopAll function", ->

    beforeEach ->
      @core.stopAll()
      @core.unregisterAll()

    it "is an accessible function", ->
      (expect typeof @core.stopAll).toEqual "function"

    it "stops all running instances", ->
      cb1 = sinon.spy()

      mod1 = (sb) ->
        init: ->
        destroy: -> cb1()

      @core.register "mod", mod1

      @core.start "mod", { instanceId: "a" }
      @core.start "mod", { instanceId: "b" }

      (expect @core.stopAll()).toBeTruthy()
      (expect cb1.callCount).toEqual 2

    it "calls the callback afterwards", (done) ->
      (expect @core.register "valid", @validModule).toBeTruthy()
      (expect @core.start "valid").toBeTruthy()
      (expect @core.start "valid", instanceId: "valid2").toBeTruthy()
      (expect @core.stopAll done).toBeTruthy()

    it "calls the callback if not destroyed in a asynchronous way", (done) ->
      cb1 = sinon.spy()
      mod = (sb) ->
        init: ->
        destroy: -> cb1()
      (expect @core.register "syncDestroy", mod).toBeTruthy()
      (expect @core.start "syncDestroy").toBeTruthy()
      (expect @core.start "syncDestroy", instanceId: "second").toBeTruthy()
      (expect @core.stopAll done).toBeTruthy()

  describe "publish function", ->
    it "is an accessible function", ->
      (expect typeof @core.publish).toEqual "function"

  describe "subscribe function", ->
    it "is an accessible function", ->
      (expect typeof @core.subscribe).toEqual "function"

  describe "unsubscribe function", ->

    it "is an accessible function", ->
      (expect typeof @core.unsubscribe).toEqual "function"

    it "removes subscriptions from a channel", (done) ->

      globalA = sinon.spy()
      globalB = sinon.spy()

      mod = (sb) ->

        init: ->
          sb.subscribe "X", globalA
          sb.subscribe "X", globalB
          sb.subscribe "Y", globalB
          switch sb.instanceId
            when "a"
              localCB = sinon.spy()
              sb.subscribe "X", localCB
            when "b"
              localCB = sinon.spy()
              sb.subscribe "X", localCB
              sb.subscribe "Y", localCB

          sb.subscribe "test1", ->
            switch sb.instanceId
              when "a"
                (expect localCB.callCount).toEqual 3
              when "b"
                (expect localCB.callCount).toEqual 2
            done()

          sb.subscribe "unregister", ->
            if sb.instanceId is "b"
              sb.unsubscribe "X"

        destroy: ->

      (expect @core.unregisterAll()).toBeTruthy()
      (expect @core.register "mod", mod).toBeTruthy()
      (expect @core.start "mod", instanceId: "a").toBeTruthy()
      (expect @core.start "mod", instanceId: "b").toBeTruthy()

      @core.publish "X", "foo"
      @core.publish "Y", "bar"

      (expect globalA.callCount).toEqual 2
      (expect globalB.callCount).toEqual 4
      @core.publish "test"

      @core.publish "unregister"
      @core.publish "X", "foo"

      (expect globalA.callCount).toEqual 3
      (expect globalB.callCount).toEqual 5

      @core.publish "X"
      @core.publish "test1"

  describe "register Plugin function", ->

    before ->

      @validPlugin =
        id: "myPluginId"
        version: "0.2.4"
        sandbox: (sb) -> { yeah: "great" }
        core: { aKey: "txt", aFunc: -> }
        base:
          foo: -> "yeah"
          bar: "x"
        on:
          instantiate: (data) ->
          destroy: (data) ->

    it "returns false if plugin is not an object", ->
      (expect @scaleApp.plugin.register "foo").toBe false

    it "returns true if plugin is valid", ->
      (expect @scaleApp.plugin.register @validPlugin).toBeTruthy()
      (expect @core.register "nice", @validModule).toBeTruthy()
      (expect @core.start "nice").toBeTruthy()

    it "installs a core plugin", ->
      (expect @scaleApp.plugin.register @validPlugin).toBeTruthy()
      c = new @scaleApp.Core
      (expect c.aKey).toEqual "txt"
      (expect c.aFunc.toString()).toEqual @validPlugin.core.aFunc.toString()

    it "installs a base plugin", ->
      (expect @scaleApp.plugin.register @validPlugin).toBe true
      (expect @scaleApp.foo).toBe @validPlugin.base.foo
      (expect @scaleApp.bar).toEqual "x"

    it "installs the sandbox plugin", (done) ->
      aModule = (sb) ->
        init: ->
          (expect sb.yeah).toEqual "great"
          done()
        destroy: ->
      @core.register "anId", aModule
      @scaleApp.plugin.register @validPlugin
      @core.start "anId"

  describe "onModuleState function", ->
    before ->
      @core.register "mod", (sb) ->
        init: ->
        destroy: ->

    it "calls a registered method on instatiation", (done) ->
      fn = (data, channel) ->
        (expect channel).toEqual "instantiate/mod"
      fn2 = (data, channel) ->
        (expect channel).toEqual "instantiate/_always"
        done()
      @core.onModuleState "instantiate", fn, "mod"
      @core.onModuleState "instantiate", fn2
      @core.start "mod"

    it "calls a registered method on destruction", (done) ->
      fn = (data, channel) ->
        (expect channel).toEqual "destroy/mod"
        done()
      @core.onModuleState "destroy", fn, "mod"
      @core.start "mod"
      @core.stop "mod"

    it "registers the plugin methods", (done) ->
      instFn = (data, channel) ->
        (expect channel).toEqual "instantiate/_always"
      destFn = (data, channel) ->
        (expect channel).toEqual "destroy/_always"
        done()

      plugin =
        id: "aplugin"
        sandbox: (sb) ->
        on:
          instantiate: instFn
          destroy: destFn
      (expect @scaleApp.plugin.register plugin).toBe true
      (expect @core.start "mod").toBe true
      (expect @core.stop "mod").toBe true
