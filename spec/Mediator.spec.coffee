if module?.exports?
  require?("./nodeSetup")()
else if window?
  window.expect = window.chai.expect

describe "Mediator", ->

  beforeEach ->
    if typeof(require) is "function"
      @Mediator = require("../dist/scaleApp").Mediator
    else if window?
      @Mediator = window.scaleApp.Mediator
    @paul = new @Mediator

  describe "on function", ->

    it "is an accessible function", ->
      (expect @paul.on).to.be.a "function"

    it "returns a subscription object", ->

      ch = "a channel"
      obj = {}
      cb1 = sinon.spy()

      sub = @paul.on ch, cb1
      sub2 = @paul.on ch, cb1, obj

      (expect sub).to.be.an "object"
      (expect sub.attach).to.be.a "function"
      (expect sub.detach).to.be.a "function"
      (expect sub).not.to.equal sub2

    it "returns false if callback is not a function", ->
      (expect @paul.on "a", 345).to.equal false

    it "has an alias method named 'on'", ->
      (expect @paul.on).to.equal @paul.on

    it "subscribes a function to several channels", ->

      cb1 = sinon.spy()
      @paul.on ["a","b"], cb1

      @paul.emit "a", "foo"
      (expect cb1.callCount).to.equal 1

      @paul.emit "b", "bar"
      (expect cb1.callCount).to.equal 2

    it "subscribes several functions to several channels", ->

      cb1 = sinon.spy()
      cb2 = sinon.spy()
      @paul.on "a":cb1,"b":cb2

      @paul.emit "a", "foo"
      (expect cb1.callCount).to.equal 1
      (expect cb2.callCount).to.equal 0

      @paul.emit "b", "bar"
      (expect cb1.callCount).to.equal 1
      (expect cb2.callCount).to.equal 1

  describe "subscription object", ->

    it "can be detached and attached", ->

      ch = "channel"
      obj = {}
      cb1 = sinon.spy()
      cb2 = sinon.spy()
      sub = @paul.on ch, cb1

      sub2 = @paul.on ch, cb2, obj
      sub2.detach()
      @paul.emit ch, "foo"
      (expect cb1.callCount).to.equal 1
      (expect cb2.callCount).to.equal 0

      sub2.attach()
      sub.detach()
      @paul.emit ch, "bar"
      (expect cb1.callCount).to.equal 1
      (expect cb2.callCount).to.equal 1

  describe "off function", ->

    it "removes a subscription from a channel", ->

      ch = "a channel"
      cb1 = sinon.spy()
      cb2 = sinon.spy()

      @paul.on ch, cb1
      @paul.on ch, cb2

      @paul.emit ch, "hello"
      @paul.off ch, cb1
      @paul.emit ch, "hello2"
      (expect cb1.callCount).to.equal 1
      (expect cb2.callCount).to.equal 2

    it "removes a callback function from all channels", ->

      ch1 = "channel1"
      ch2 = "channel2"
      cb1 = sinon.spy()
      cb2 = sinon.spy()

      @paul.on ch1, cb1
      @paul.on ch2, cb1, {}
      @paul.on ch1, cb2

      @paul.off cb1

      @paul.emit ch1, "hello"
      @paul.emit ch2, "hello"

      (expect cb1).not.to.have.been.called
      (expect cb2.callCount).to.equal 1

    it "removes all subscriptions of a context", ->

      ch1 = "channel1"
      ch2 = "channel2"
      cb1 = sinon.spy()
      cb2 = sinon.spy()
      obj = {}
      mediator = new @Mediator
      mediator.installTo obj

      mediator.on ch1, cb1
      obj.on ch1, cb1
      obj.on ch2, cb2

      mediator.emit ch1, "hello"
      obj.emit ch1, "world"
      obj.emit ch2, "foo"

      (expect cb1.callCount).to.equal 4
      (expect cb2.callCount).to.equal 1

      obj.off()
      mediator.emit ch1, "hello"
      obj.emit ch1, "world"
      obj.emit ch2, "foo"

      (expect cb1.callCount).to.equal 6
      (expect cb2.callCount).to.equal 1

    it "removes all subscriptions from a channel", ->

      ch1 = "channel1"
      ch2 = "channel2"
      cb1 = sinon.spy()
      cb2 = sinon.spy()
      obj = {}
      mediator = new @Mediator
      mediator.installTo obj

      mediator.on ch1, cb1
      obj.on ch1, cb1
      obj.on ch2, cb2

      mediator.emit ch1, "hello"
      obj.emit ch1, "world"
      obj.emit ch2, "foo"

      (expect cb1.callCount).to.equal 4
      (expect cb2.callCount).to.equal 1

      obj.off ch2
      mediator.emit ch1, "hello"
      obj.emit ch1, "world"
      obj.emit ch2, "foo"

      (expect cb1.callCount).to.equal 8
      (expect cb2.callCount).to.equal 1

  describe "publish function", ->

    it "is an accessible function", ->
      (expect @paul.emit).to.be.a "function"

    it "has an alias method named 'emit'", ->
      (expect @paul.emit).to.equal @paul.emit

    it "returns the current context", ->
      (expect @paul.emit "my channel", {}).to.equal @paul
      (expect (new @Mediator).on "my channel", ->).not.to.equal @paul

    it "calls the callback if it is defined", (done) ->
      cb = sinon.spy()
      @paul.on "event", cb
      @paul.emit "event", {}, () ->
        (expect cb.callCount).to.equal 1
        done()

    it "calls the callback even if there are not subscribers", (done) ->
      m1 = new @Mediator
      m2 = new @Mediator
      m1.emit "x", (err)->
        (expect err?).to.be.false
        m2.emit "x", "foo", (err)->
          (expect err?).to.be.false
          done()

    it "passes an error if a callback returned false", (done) ->
      cb = sinon.spy()
      @paul.on "event", ->
        cb()
        false
      @paul.emit "event", {}, (err) ->
        (expect err).not.to.be.null
        done()


    it "calls the callback asynchronously", (done) ->
      cb  = sinon.spy()
      cb2 = sinon.spy()
      @paul.on "event", (data, channel, next) ->
        setTimeout (-> cb(); next null), 3
      @paul.on "event", (data, channel, x) ->
        setTimeout (-> cb2(); x null), 2
      @paul.emit "event", {}, (err) ->
        (expect cb.callCount).to.equal 1
        (expect cb2.callCount).to.equal 1
        (expect err?).to.be.false
        done()

    it "calls the callback asynchronously and looks for errors", (done) ->
      @paul.on "event", (data, channel, next) ->
        setTimeout (-> next null), 1
      @paul.on "event", (data, channel, x) ->
        setTimeout (-> x new Error "fake1"), 1
      @paul.on "event", (data, channel, x) ->
        x new Error "fake2"
      @paul.emit "event", {}, (err) ->
        (expect err.message).to.equal "fake1; fake2"
        done()

  describe "send function", ->

    it "is an accessible function", ->
      (expect @paul.send).to.be.a "function"

    it "returns the current context", ->
      (expect @paul.send "my channel", {}).to.equal @paul
      (expect (new @Mediator).on "my channel", ->).not.to.equal @paul

    it "calls the callback if it is defined", (done) ->
      cb = sinon.spy()
      @paul.on "event", cb
      @paul.send "event", {}, (err) ->
        (expect cb.callCount).to.equal 1
        done()

    it "calls the callback even if there are not subscribers", (done) ->
      m1 = new @Mediator
      m2 = new @Mediator
      m1.send "x", (err)->
        (expect err?).to.be.false
        m2.send "x", "foo", (err, reply)->
          (expect err?).to.be.false
          (expect reply?).to.be.false
          done()

    it "passes an error if a callback returned false", (done) ->
      cb = sinon.spy()
      @paul.on "event", ->
        cb()
        false
      @paul.send "event", {}, (err) ->
        (expect cb.callCount).to.equal 1
        (expect err).not.to.be.null
        done()

    it "calls the callback asynchronously", (done) ->
      cb1 = sinon.spy()
      cb2 = sinon.spy()
      @paul.on "event", (data, channel, next) ->
        setTimeout (-> cb1(); next null, 'one'), 3
      @paul.on "event", (data, channel, x) ->
        setTimeout (-> cb2(); x null, 'tow'), 2
      @paul.send "event", {}, (err, reply) ->
        (expect cb1.callCount).to.equal 1
        (expect cb2.callCount).to.equal 0
        (expect err?).to.be.false
        (expect reply).to.equal 'one'
        done()

    it "calls the callback asynchronously and force errors", (done) ->
      @paul.on "event", (data, channel, x) ->
        setTimeout (-> x new Error "fake1"), 1
      @paul.on "event", (data, channel, next) ->
        setTimeout (-> next null, "tow", "some"), 1
      @paul.on "event", (data, channel, x) ->
        x new Error "fake2"
      @paul.send "event", {}, (err, reply) ->
        (expect err?).to.be.false
        (expect reply).to.eql ["tow", "some"]
        done()

    it "calls the callback asynchronously and pass errors", (done) ->
      @paul.on "event", (data, channel, x) ->
        setTimeout (-> x new Error "fake1"), 3
      @paul.on "event", (data, channel, next) ->
        setTimeout (-> next new Error "fake2"), 1
      @paul.on "event", (data, channel, x) ->
        x new Error "fake3"
      @paul.send "event", {}, (err, reply) ->
        (expect reply?).to.be.false
        (expect err?).not.to.be.false
        (expect err.message).to.equal "fake1; fake2; fake3"
        done()

  describe "installTo function", ->

    it "is an accessible function", ->
      (expect @paul.installTo).to.be.a "function"

    it "installs the mediator functions", ->

      cb = sinon.spy()
      cb2 = sinon.spy()
      mediator = new @Mediator
      myObj = {}
      mediator.installTo myObj

      (expect myObj.on).to.be.a "function"
      (expect myObj.emit).to.be.a "function"
      (expect myObj.send).to.be.a "function"
      (expect myObj.off).to.be.a "function"
      (expect myObj.channels).to.be.an "object"

      myObj.on "ch", cb
      mediator.on "ch", cb2
      mediator.on "ch2", cb2

      myObj.emit "ch", "foo"
      mediator.emit "ch", "bar"
      mediator.send "ch", "bar"
      mediator.emit "ch2", "blub"
      mediator.send "ch2", "blub"

      (expect cb.callCount).to.equal 3
      (expect cb2.callCount).to.equal 4

    it "takes care of the context", (done) ->

      mediator = new @Mediator
      myObj = {}
      empty = {}
      mediator.installTo myObj

      myObj.on "ch", -> (expect @).to.equal myObj
      mediator.on "ch", -> (expect @).to.equal mediator
      mediator.on "ch", (-> (expect @).to.equal empty), empty

      myObj.emit "ch", "foo"
      mediator.emit "ch", "bar"

      myObj.send "ch", "foo"
      mediator.send "ch", "bar"
      done()

    it "installs the mediator functions on creation", ->
      myObj = {}
      new @Mediator myObj
      (expect myObj.on).to.be.a "function"
      (expect myObj.emit).to.be.a "function"
      (expect myObj.send).to.be.a "function"
      (expect myObj.off).to.be.a "function"
      (expect myObj.channels).to.be.an "object"

    it "returns the current context", ->
      (expect @paul.installTo {}).to.equal @paul
      (expect (new @Mediator).installTo {}).not.to.equal @paul

    it "overrides methods if 'force' is set", ->
      m = new @Mediator
      o = { on: "foo" }
      m.installTo o
      (expect o.on).to.equal "foo"
      m.installTo o, true
      (expect o.on).to.equal m.on

  describe "Pub/Sub", ->

    beforeEach ->
      @peter = new @Mediator
      @data = { bla: "blub"}
      @cb  = sinon.spy()
      @cb1 = sinon.spy()
      @cb2 = sinon.spy()
      @cb3 = sinon.spy()
      @anObject = {}

    it "publishes data to a subscribed topic", ->

      @paul.on  "a channel", @cb
      @paul.installTo @anObject
      @anObject.on "a channel", @cb
      @peter.on "a channel", @cb2
      @paul.emit "a channel", @data
      @paul.emit "does not exist", @data
      (expect @cb.callCount).to.equal 2
      (expect @cb2).not.to.have.been.called

    it "send data to a subscribed topic", ->

      @paul.on  "a channel", @cb
      @paul.installTo @anObject
      @anObject.on "a channel", @cb
      @peter.on "a channel", @cb2
      @paul.send "a channel", @data
      @paul.send "does not exist", @data
      (expect @cb.callCount).to.equal 1
      (expect @cb2).not.to.have.been.called

    it "publishes data to all subscribers even if an error occours", ->
      cb = sinon.spy()
      @paul.on "channel", -> cb()
      @paul.on "channel", -> (throw new Error "err"); cb()
      @paul.on "channel", -> cb()
      @paul.emit "channel"
      (expect cb.callCount).to.equal 2

    it "publishes the reference of data objects by default", (done) ->

      obj = {a:true,b:"x",c:{ y:0 }}

      @paul.on "obj", (data) ->
        (expect data).to.equal obj
        (expect data is obj).to.be.true
        done()

      @paul.emit "obj", obj

    it "send the reference of data objects by default", (done) ->

      obj = {a:true,b:"x",c:{ y:0 }}

      @paul.on "obj", (data) ->
        (expect data).to.equal obj
        (expect data is obj).to.be.true
        done()

      @paul.send "obj", obj

    it "does not publish/send data to other topics", ->
      @paul.on "a channel", @cb
      @paul.emit "another channel", @data
      @paul.send "another channel", @data
      (expect @cb).not.to.have.been.called

    it "can request data by publishing an event", (done) ->

      # lets say we have database with user objects
      db = [
        { name: "markus", role: "admin" }
        { name: "paul",   role: "user" }
      ]

      # we could use a mediator as public API
      @dbAccess = new @Mediator

      # then we bind the read event to our database
      @dbAccess.on "read", (r) ->
        # process the query
        result = []
        for user in db
          result.push user for k,v of r.query when user[k] is v
        # send results
        r.receive null, result

      # receive a list of users by publishing a read event
      @dbAccess.emit "read",
        query: { role: "admin" }
        receive: (err, data) ->
          (expect data.length).to.equal 1
          (expect data[0]).to.eql { name: "markus", role: "admin" }
          done()

    it "can request data by send an event", (done) ->
      spy = sinon.spy()

      # lets say we have database with user objects
      db = [
        { name: "markus", role: "admin" }
        { name: "paul",   role: "user" }
      ]

      # we could use a mediator as public API
      @dbAccess = new @Mediator

      # then we bind the read event to our primary database
      @dbAccess.on "read", (query, channel, reply) ->
        # prcocess the query
        # .. but something went wrong
        reply new Error('Error during database access');

      # common query handler
      dbQueryHandler = (query, channel, reply) ->
        # prcocess the query
        result = []
        for user in db
          result.push user for k,v of query when user[k] is v
        spy();
        # send results
        reply null, result

      # bind the read event to our redundant database №1
      @dbAccess.on "read", dbQueryHandler
      # bind the read event to our redundant database №2
      @dbAccess.on "read", dbQueryHandler

      # receive a list of users by send a read event
      @dbAccess.send "read", { role: "admin" }, (err, data) ->
        (expect data.length).to.equal 1
        (expect data[0]).to.eql { name: "markus", role: "admin" }
        # was sent only one query to the database
        (expect spy.calledOnce).to.be.true;
        done()

    describe "auto subscription", ->

      it "publishes subtopics to parent topics", ->

        @paul.cascadeChannels = true
        @paul.on "parentTopic", @cb
        @paul.on "parentTopic/subTopic", @cb1
        @paul.on "parentTopic/subTopic/subsub", @cb2
        @paul.on "parentTopic/otherSubTopic", @cb3

        @paul.emit "parentTopic/subTopic/subsub", @data
        (expect @cb).to.have.been.called
        (expect @cb1).to.have.been.called
        (expect @cb2).to.have.been.called
        (expect @cb3).not.to.have.been.called

      it "doesn't send subtopics to parent topics", ->

        @paul.cascadeChannels = true
        @paul.on "parentTopic", @cb
        @paul.on "parentTopic/subTopic", @cb1
        @paul.on "parentTopic/subTopic/subsub", @cb2
        @paul.on "parentTopic/otherSubTopic", @cb3

        @paul.send "parentTopic/subTopic/subsub", @data
        (expect @cb).not.to.have.been.called
        (expect @cb1).not.to.have.been.called
        (expect @cb2).to.have.been.called
        (expect @cb3).not.to.have.been.called
