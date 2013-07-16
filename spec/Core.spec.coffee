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

  describe "register function", ->

    it "is an accessible function", ->
      (expect typeof @core).toEqual "object"

    it "registers a valid module", ->
      (expect @core.register "myModule", @validModule).toBe @core
      (expect @core._modules["myModule"].creator).toBe @validModule

    it "doesn't register the module if the creator is an object", ->
      (expect @core.register "myObjectModule", {}).toBe @core
      (expect @core._modules["myObjectModule"]).not.toBeDefined()

    it "registers a module if option parameter is an object", ->
      (expect @core.register "myModule", @validModule).toBe @core
      (expect @core._modules["myModule"].creator).toBe @validModule

    it "doesn't register the module if the option parameter isn't an object", ->
      (expect @core.register "myModuleWithWrongObj", @validModule, "I'm not an object" ).toBe @core
      (expect @core._modules["myModuleWithWrongObj"]).not.toBeDefined()

  describe "list methods", ->

    before ->
      @core.stop()
      @core.register "myModule", @validModule

  describe "start function", ->

    before ->
      @core.stop()
      @core.register "myId", @validModule

    it "is an accessible function", ->
      (expect typeof @core.start).toEqual "function"

    describe "start parameters", ->

      it "doesn't return an error if first parameter is a string", (done)->
        @core.start "myId", (err) =>
          (expect err).not.toBeDefined()
          done()

      it "doesn't return an error if second parameter is a an object", (done)->
        @core.start "myId",
          callback: (err) ->
            (expect err).not.toBeDefined()
            done()

      it "returns an error if second parameter is a number", (done)->
        @core.start "myId", 123, (err) ->
          (expect err).toBeDefined()
          done()

      it "returns an error if module does not exist", (done)->
        @core.start "foo", (err) ->
          (expect err).toBeTruthy()
          done()

      it "doesn't return an error if module exist", (done)->
        @core.start "myId", (err) ->
          (expect err).not.toBeTruthy()
          done()

      it "returns an error if instance was aleready started", (done) ->
        @core.start "myId", =>
          @core.start "myId", (err) ->
            (expect err).toBeTruthy()
            done()

      it "passes the options", (done) ->
        mod = (sb) ->
          init: (opt) ->
            (expect typeof opt).toEqual "object"
            (expect opt.foo).toEqual "bar"
            done()
        @core.register "foo", mod
        @core.start "foo", options: {foo: "bar"}

      it "calls the callback function after the initialization", (done) ->

        x     = 0
        cb    = -> (expect x).toBe(2); done()

        @core.register "anId", (sb) ->
          init: (opt, fini) ->
            setTimeout (-> x = 2; fini()), 0
            x = 1

        @core.start "anId", (err) =>
          @core.start "anId",
            instanceId: "foo"
            callback: cb

      it "calls the callback immediately if no callback was defined", ->
        cb = sinon.spy()
        mod1 = (sb) ->
          init: (opt) ->
        (expect @core.register "anId", mod1).toBe @core
        @core.start "anId", { callback: cb }
        (expect cb).toHaveBeenCalled()

      it "calls the callback function with an error if an error occours", (done) ->
        initCB = sinon.spy()
        mod1 = (sb) ->
          init: ->
            initCB()
            thisWillProcuceAnError()
        (expect @core.register "anId", mod1).toBe @core
        @core.start "anId",
          callback: (err)->
            (expect initCB).toHaveBeenCalled()
            (expect err.message).toEqual "could not start module: thisWillProcuceAnError is not defined"
            done()

      it "starts a separate instance", ->

        initCB = sinon.spy()
        mod1 = (sb) ->
          init: -> initCB()

        (expect @core.register "separate", mod1).toBe @core
        @core.start "separate", { instanceId: "instance" }
        (expect initCB).toHaveBeenCalled()

  describe "start all", ->

    before ->
      @core.stop()

    it "instantiates and starts all available modules", ->

      cb1 = sinon.spy()
      cb2 = sinon.spy()

      mod1 = (sb) ->
        init: -> cb1()

      mod2 = (sb) ->
        init: -> cb2()

      (expect @core.register "first", mod1 ).toBe @core
      (expect @core.register "second", mod2).toBe @core

      (expect cb1).not.toHaveBeenCalled()
      (expect cb2).not.toHaveBeenCalled()

      (expect @core.start()).toBe @core
      (expect cb1).toHaveBeenCalled()
      (expect cb2).toHaveBeenCalled()

    it "starts all modules of the passed array", ->

      cb1 = sinon.spy()
      cb2 = sinon.spy()
      cb3 = sinon.spy()

      mod1 = (sb) ->
        init: -> cb1()

      mod2 = (sb) ->
        init: -> cb2()

      mod3 = (sb) ->
        init: -> cb3()

      @core.stop()

      (expect @core.register "first", mod1 ).toBe @core
      (expect @core.register "second",mod2 ).toBe @core
      (expect @core.register "third", mod3 ).toBe @core

      (expect cb1).not.toHaveBeenCalled()
      (expect cb2).not.toHaveBeenCalled()
      (expect cb3).not.toHaveBeenCalled()

      (expect @core.start ["first","third"]).toBe @core
      (expect cb1).toHaveBeenCalled()
      (expect cb2).not.toHaveBeenCalled()
      (expect cb3).toHaveBeenCalled()

    it "calls the callback function after all modules have started", (done) ->

      cb1 = sinon.spy()

      sync = (sb) ->
        init: (opt)->
          (expect cb1).not.toHaveBeenCalled()
          cb1()

      pseudoAsync = (sb) ->
        init: (opt, done)->
          (expect cb1.callCount).toEqual 1
          cb1()
          done()

      async = (sb) ->
        init: (opt, done)->
          setTimeout (->
            (expect cb1.callCount).toEqual 2
            cb1()
            done()
          ), 0

      @core.register "first", sync
      @core.register "second", async
      @core.register "third", pseudoAsync

      (expect @core.start ->
        (expect cb1.callCount).toEqual 3
        done()
      ).toBe @core

    it "calls the callback after defined modules have started", (done) ->

      finished = sinon.spy()

      cb1 = sinon.spy()
      cb2 = sinon.spy()

      mod1 = (sb) ->
        init: (opt, done)->
          setTimeout (->done()), 0
          (expect finished).not.toHaveBeenCalled()

      mod2 = (sb) ->
        init: (opt, done) ->
          setTimeout (-> done()), 0
          (expect finished).not.toHaveBeenCalled()

      @core.register "first", mod1, { callback: cb1 }
      @core.register "second", mod2, { callback: cb2 }

      (expect @core.start ["first","second"], ->
        finished()
        (expect cb1).toHaveBeenCalled()
        (expect cb2).toHaveBeenCalled()
        done()
      ).toBe @core

    it "calls the callback with an error if one or more modules couldn't start", (done) ->
      spy1 = sinon.spy()
      spy2 = sinon.spy()
      mod1 = (sb) ->
        init: -> spy1(); thisIsAnInvalidMethod()
      mod2 = (sb) ->
        init: -> spy2()
      @core.register "invalid", mod1
      @core.register "valid", mod2
      @core.start ["invalid", "valid"], (err) ->
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
      @core.register "valid", @validModule
      @core.register "x", mod
      finished = (err) ->
        (expect err.message).toEqual "these modules don't exist: 'invalid','y'"
        done()
      (expect @core.start ["valid","invalid", "x", "y"], finished).toBe @core
      (expect spy2).toHaveBeenCalled()

    it "calls the callback without an error if module array is empty", ->
      spy = sinon.spy()
      finished = (err) ->
        (expect err).toEqual null
        spy()
      (expect @core.start [], finished).toBe @core
      (expect spy).toHaveBeenCalled()

  describe "stop function", ->

    beforeEach ->
      @core.stop()

    it "is an accessible function", ->
      (expect typeof @core.stop).toEqual "function"

    it "calls the callback afterwards", (done) ->
      (expect @core.register "valid", @validModule).toBe @core
      (expect @core.start "valid").toBe @core
      (expect @core.stop "valid", done).toBe @core

    it "supports synchronous stopping", ->
      mod = (sb) ->
        init: ->
      end = false
      (expect @core.register "mod", mod).toBeTruthy()
      (expect @core.start "mod").toBeTruthy()
      (expect @core.stop "mod", -> end = true).toBeTruthy()
      (expect end).toEqual true

  describe "stop all function", ->

    beforeEach ->
      @core.stop()

    it "stops all running instances", ->
      cb1 = sinon.spy()

      mod1 = (sb) ->
        init: ->
        destroy: -> cb1()

      @core.register "mod", mod1

      @core.start "mod", { instanceId: "a" }
      @core.start "mod", { instanceId: "b" }

      (expect @core.stop()).toBe @core
      (expect cb1.callCount).toEqual 2

    it "calls the callback afterwards", (done) ->
      (expect @core.register "valid", @validModule).toBe @core
      (expect @core.start "valid").toBe @core
      (expect @core.start "valid", instanceId: "valid2").toBe @core
      (expect @core.stop (err) ->
        (expect err).toBeFalsy()
        done()
      ).toBe @core

    it "calls the callback if not destroyed in a asynchronous way", (done) ->
      cb1 = sinon.spy()
      mod = (sb) ->
        init: ->
        destroy: -> cb1()
      (expect @core.register "syncDestroy", mod).toBe @core
      (expect @core.start "syncDestroy").toBe @core
      (expect @core.start "syncDestroy", instanceId: "second").toBe @core
      (expect @core.stop done).toBe @core

  describe "emit function", ->
    it "is an accessible function", ->
      (expect typeof @core.emit).toEqual "function"

  describe "on function", ->
    it "is an accessible function", ->
      (expect typeof @core.on).toEqual "function"

  describe "off function", ->

    it "is an accessible function", ->
      (expect typeof @core.off).toEqual "function"

    it "removes subscriptions from a channel", (done) ->

      globalA = sinon.spy()
      globalB = sinon.spy()

      mod = (sb) ->

        init: ->
          sb.on "X", globalA
          sb.on "X", globalB
          sb.on "Y", globalB
          switch sb.instanceId
            when "a"
              localCB = sinon.spy()
              sb.on "X", localCB
            when "b"
              localCB = sinon.spy()
              sb.on "X", localCB
              sb.on "Y", localCB

          sb.on "test1", ->
            switch sb.instanceId
              when "a"
                (expect localCB.callCount).toEqual 3
              when "b"
                (expect localCB.callCount).toEqual 2
            done()

          sb.on "unregister", ->
            if sb.instanceId is "b"
              sb.off "X"

      (expect @core.register "mod", mod).toBeTruthy()
      (expect @core.start "mod", instanceId: "a").toBeTruthy()
      (expect @core.start "mod", instanceId: "b").toBeTruthy()

      @core.emit "X", "foo"
      @core.emit "Y", "bar"

      (expect globalA.callCount).toEqual 2
      (expect globalB.callCount).toEqual 4
      @core.emit "test"

      @core.emit "unregister"
      @core.emit "X", "foo"

      (expect globalA.callCount).toEqual 3
      (expect globalB.callCount).toEqual 5

      @core.emit "X"
      @core.emit "test1"

  describe "use Plugin function", ->

    before ->

      @validPlugin = (core, options) ->
        init: (sb) ->
          sb.sync = true
        id: "myPluginId"

      @validAsyncPlugin = (core, opts, done) ->
        core.Sandbox::foo = -> @instanceId
        next = ->
          core.dynFunc = ->
          done()
        setTimeout next, 0

        init: (sb, opts, done) ->
          sb.bar = -> "foo"
          done()

    it "does not regsiter a plugin if it is not a function", ->
      (expect @core.use("foo")._plugins.length).toBe 0

    it "registers a plugin if it's a function", ->
      (expect @core.use(->)._plugins.length).toBe 1

    it "registers an array of plugins", ->
      (expect @core.use([(->),(->)])._plugins.length).toBe 2

    it "registers an array of plugins objects", ->
      (expect @core.use([
        {plugin: (->), options: {}}
        {plugin: ->               }
        {foo: ->                  }
        (->)
      ])._plugins.length).toBe 3

    it "installs a plugin", ->
      c = new @scaleApp.Core
      c.use (core) -> core.aKey = "txt"
      (expect c._plugins.length).toBe 1
      c.boot()
      (expect c.aKey).toEqual "txt"

    it "installs the asynchronous core plugin", (done) ->
      c = new @scaleApp.Core
      c.use @validAsyncPlugin
      c.boot (err) =>
        (expect err).toBeFalsy()
        (expect typeof c.dynFunc).toBe "function"
        done()
      (expect c.dynFunc).not.toBeDefined()

    it "installs the sandbox plugin", (done) ->
      aModule = (sb) ->
        init: ->
          (expect sb.sync).toBe true
          done()
      @core.register "anId", aModule
      @core.use @validPlugin
      @core.start "anId"

    it "installs the async sandbox plugin", (done) ->
      aModule = (sb) ->
        init: ->
          (expect sb.foo()).toEqual "anId"
          (expect sb.bar()).toEqual "foo"
          done()
      @core.register "anId", aModule
      @core.use @validAsyncPlugin
      @core.start "anId"
