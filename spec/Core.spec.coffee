if module?.exports?
  require?("./nodeSetup")()
else if window?
  window.expect = window.chai.expect

describe "scaleApp core", ->

  pause = (ms) ->
    ms += (new Date).getTime()
    continue while ms > new Date()

  beforeEach ->

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
      (expect @core).to.be.an "object"

    it "registers a valid module", ->
      (expect @core.register "myModule", @validModule).to.equal @core
      (expect @core._modules["myModule"].creator).to.equal @validModule

    it "doesn't register the module if the creator is an object", ->
      (expect @core.register "myObjectModule", {}).to.equal @core
      (expect @core._modules["myObjectModule"]).not.to.exist

    it "registers a module if option parameter is an object", ->
      (expect @core.register "myModule", @validModule).to.equal @core
      (expect @core._modules["myModule"].creator).to.equal @validModule

    it "doesn't register the module if the option parameter isn't an object", ->
      (expect @core.register "myModuleWithWrongObj", @validModule, "I'm not an object" ).to.equal @core
      (expect @core._modules["myModuleWithWrongObj"]).not.to.exist

  describe "start function", ->

    beforeEach ->
      @core.stop()
      @core.register "myId", @validModule

    it "is an accessible function", ->
      (expect @core.start).to.be.a "function"

    describe "start parameters", ->

      it "doesn't return an error if first parameter is a string", (done)->
        @core.start "myId", (err) =>
          (expect err).not.to.exist
          done()

      it "doesn't return an error if second parameter is a an object", (done)->
        @core.start "myId", (err) ->
            (expect err).not.to.exist
            done()

      it "returns an error if second parameter is a number", (done)->
        @core.start "myId", 123, (err) ->
          (expect err).to.exist
          done()

      it "returns an error if module does not exist", (done)->
        @core.start "foo", (err) ->
          (expect err).to.exist
          done()

      it "doesn't return an error if module exist", (done)->
        @core.start "myId", (err) ->
          (expect err).not.to.exist
          done()

      it "returns an error if instance was aleready started", (done) ->
        @core.start "myId", =>
          @core.start "myId", (err) ->
            (expect err).to.exist
            done()

      it "passes the options", (done) ->
        mod = (sb) ->
          init: (opt) ->
            (expect opt).to.be.an "object"
            (expect opt.foo).to.equal "bar"
            done()
        @core.register "foo", mod
        @core.start "foo", options: {foo: "bar"}

      it "appends the moduleId and instanceId", (done) ->
        mod = (sb) ->
          init: (opt) ->
            (expect sb.instanceId).to.equal "x"
            (expect sb.moduleId).to.equal "foo"
            done()
        @core.register "foo", mod
        @core.start "foo", instanceId: "x", options: {foo: "bar"}

      it "takes a custom sandbox", (done) ->
        myTempSandbox = ->

        mod = (sb) ->
          init: (opt) ->
            (expect sb instanceof myTempSandbox).to.be.true
            done()
        @core.register "baz", mod
        @core.start "baz", sandbox: myTempSandbox

      it "calls the callback function after the initialization", (done) ->

        x     = 0
        cb    = -> (expect x).to.equal(2); done()

        @core.register "anId", (sb) ->
          init: (opt, fini) ->
            setTimeout (-> x = 2; fini()), 0
            x = 1

        @core.start "anId", (err) =>
          @core.start "anId", { instanceId: "foo" }, cb

      it "calls the callback immediately if no callback was defined", ->
        cb = sinon.spy()
        mod1 = (sb) ->
          init: (opt) ->
        (expect @core.register "anId", mod1).to.equal @core
        @core.start "anId", cb
        (expect cb).to.have.been.called

      it "calls the callback function with an error if an error occours", (done) ->
        initCB = sinon.spy()
        mod1 = (sb) ->
          init: ->
            initCB()
            thisWillProcuceAnError()
        (expect @core.register "anId", mod1).to.equal @core
        @core.start "anId", (err)->
            (expect initCB).to.have.been.called
            (expect err.message.indexOf("could not start module:") >= 0).to.be.true
            (expect err.message.indexOf("thisWillProcuceAnError") >= 0).to.be.true
            done()

      it "starts a separate instance", ->

        initCB = sinon.spy()
        mod1 = (sb) ->
          init: -> initCB()

        (expect @core.register "separate", mod1).to.equal @core
        @core.start "separate", { instanceId: "instance" }
        (expect initCB).to.have.been.called

  describe "start all", ->

    beforeEach -> @core.stop()

    it "instantiates and starts all available modules", ->

      cb1 = sinon.spy()
      cb2 = sinon.spy()

      mod1 = (sb) ->
        init: -> cb1()

      mod2 = (sb) ->
        init: -> cb2()

      (expect @core.register "first", mod1 ).to.equal @core
      (expect @core.register "second", mod2).to.equal @core

      (expect cb1).not.to.have.been.called
      (expect cb2).not.to.have.been.called

      (expect @core.start()).to.equal @core
      (expect cb1).to.have.been.called
      (expect cb2).to.have.been.called

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

      (expect @core.register "first", mod1 ).to.equal @core
      (expect @core.register "second",mod2 ).to.equal @core
      (expect @core.register "third", mod3 ).to.equal @core

      (expect cb1).not.to.have.been.called
      (expect cb2).not.to.have.been.called
      (expect cb3).not.to.have.been.called

      (expect @core.start ["first","third"]).to.equal @core
      (expect cb1).to.have.been.called
      (expect cb2).not.to.have.been.called
      (expect cb3).to.have.been.called

    it "calls the callback function after all modules have started", (done) ->

      cb1 = sinon.spy()

      sync = (sb) ->
        init: (opt)->
          (expect cb1).not.to.have.been.called
          cb1()

      pseudoAsync = (sb) ->
        init: (opt, done)->
          (expect cb1.callCount).to.equal 1
          cb1()
          done()

      async = (sb) ->
        init: (opt, done)->
          setTimeout (->
            (expect cb1.callCount).to.equal 2
            cb1()
            done()
          ), 0

      @core.register "first", sync
      @core.register "second", async
      @core.register "third", pseudoAsync

      (expect @core.start ->
        (expect cb1.callCount).to.equal 3
        done()
      ).to.equal @core

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
        (expect spy1).to.have.been.called
        (expect spy2).to.have.been.called
        (expect err.message).to.equal "errors occoured in the following modules: 'invalid'"
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
        (expect err.message).to.equal "errors occoured in the following modules: 'invalid','y'"
        done()
      (expect @core.start ["valid","invalid", "x", "y"], finished).to.equal @core
      (expect spy2).to.have.been.called

    it "calls the callback without an error if module array is empty", ->
      spy = sinon.spy()
      finished = (err) ->
        (expect err).not.to.exist
        spy()
      (expect @core.start [], finished).to.equal @core
      (expect spy).to.have.been.called

  describe "stop function", ->

    beforeEach -> @core.stop()

    it "is an accessible function", ->
      (expect @core.stop).to.be.a "function"

    it "calls the callback afterwards", (done) ->
      (expect @core.register "valid", @validModule).to.equal @core
      (expect @core.start "valid").to.equal @core
      (expect @core.stop "valid", (err) =>
        (expect err?).to.equal false
        (expect @core._running["valid"]?).to.equal false
        done()
      ).to.equal @core

    it "supports synchronous stopping", ->
      mod = (sb) ->
        init: ->
      end = false
      (expect @core.register "mod", mod).to.be.ok
      (expect @core.start "mod").to.be.ok
      (expect @core.stop "mod", -> end = true).to.be.ok
      (expect end).to.equal true

  describe "stop all function", ->

    beforeEach -> @core.stop()

    it "stops all running instances", ->
      cb1 = sinon.spy()

      mod1 = (sb) ->
        init: ->
        destroy: -> cb1()

      @core.register "mod", mod1

      @core.start "mod", { instanceId: "a" }
      @core.start "mod", { instanceId: "b" }

      (expect @core.stop()).to.equal @core
      (expect cb1.callCount).to.equal 2

    it "calls the callback afterwards", (done) ->
      (expect @core.register "valid", @validModule).to.equal @core
      (expect @core.start "valid").to.equal @core
      (expect @core.start "valid", instanceId: "valid2").to.equal @core
      @core.stop (err) ->
        (expect err).not.to.exist
        done()

    it "calls the callback if not destroyed in a asynchronous way", (done) ->
      cb1 = sinon.spy()
      mod = (sb) ->
        init: ->
        destroy: -> cb1()
      (expect @core.register "syncDestroy", mod).to.equal @core
      (expect @core.start "syncDestroy").to.equal @core
      (expect @core.start "syncDestroy", instanceId: "second").to.equal @core
      (expect @core.stop done).to.equal @core

  describe "emit function", ->
    it "is an accessible function", ->
      (expect @core.emit).to.be.a "function"

  describe "on function", ->
    it "is an accessible function", ->
      (expect @core.on).to.be.a "function"

  describe "off function", ->

    it "is an accessible function", ->
      (expect @core.off).to.be.a "function"

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
                (expect localCB.callCount).to.equal 3
              when "b"
                (expect localCB.callCount).to.equal 2

          sb.on "unregister", ->
            if sb.instanceId is "b"
              sb.off "X"

      @core.register "mod", mod
      @core.start "mod", instanceId: "a"
      @core.start "mod", instanceId: "b"

      @core.emit "X", "foo"
      @core.emit "Y", "bar"

      (expect globalA.callCount).to.equal 2
      (expect globalB.callCount).to.equal 4
      @core.emit "test"

      @core.emit "unregister"
      @core.emit "X", "foo"

      (expect globalA.callCount).to.equal 3
      (expect globalB.callCount).to.equal 5

      @core.emit "X"
      @core.emit "test1"
      setTimeout done, 0

  describe "use Plugin function", ->

    beforeEach ->

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
      (expect @core.use("foo")._plugins.length).to.equal 0

    it "registers a plugin if it's a function", ->
      (expect @core.use(->)._plugins.length).to.equal 1

    it "registers an array of plugins", ->
      (expect @core.use([(->),(->)])._plugins.length).to.equal 2

    it "registers an array of plugins objects", ->
      (expect @core.use([
        {plugin: (->), options: {}}
        {plugin: ->               }
        {foo: ->                  }
        (->)
      ])._plugins.length).to.equal 3

    it "installs a plugin", ->
      c = new @scaleApp.Core
      c.use (core) -> core.aKey = "txt"
      (expect c._plugins.length).to.equal 1
      c.boot()
      (expect c.aKey).to.equal "txt"

    it "installs the asynchronous core plugin", (done) ->
      c = new @scaleApp.Core
      c.use @validAsyncPlugin
      c.boot (err) =>
        (expect err).not.to.exist
        (expect c.dynFunc).to.be.a "function"
        done()
      (expect c.dynFunc).not.to.exist

    it "installs the sandbox plugin", (done) ->
      aModule = (sb) ->
        init: ->
          (expect sb.sync).to.be.true
          done()
      @core.register "anId", aModule
      @core.use @validPlugin
      @core.start "anId"

    it "installs the async sandbox plugin", (done) ->
      aModule = (sb) ->
        init: ->
          (expect sb.foo()).to.equal "anId"
          (expect sb.bar()).to.equal "foo"
          done()
      @core.register "anId", aModule
      @core.use @validAsyncPlugin
      @core.start "anId"
