require?("./nodeSetup")()

describe "Mediator", ->

  before ->
    if typeof(require) is "function"
      @Mediator = require("../dist/scaleApp").Mediator
    else if window?
      @Mediator = window.scaleApp.Mediator
    @paul = new @Mediator

  describe "on function", ->

    it "is an accessible function", ->
      (expect typeof @paul.on).toEqual "function"

    it "returns a subscription object", ->

      ch = "a channel"
      obj = {}
      cb1 = sinon.spy()
      cb2 = sinon.spy()

      sub = @paul.on ch, cb1
      sub2 = @paul.on ch, cb1, obj

      (expect typeof sub).toEqual "object"
      (expect typeof sub.attach).toEqual "function"
      (expect typeof sub.detach).toEqual "function"
      (expect sub).not.toEqual sub2

    it "returns false if callback is not a function", ->
      (expect @paul.on "a", 345).toEqual false

    it "has an alias method named 'on'", ->
      (expect @paul.on).toEqual @paul.on

    it "subscribes a function to several channels", ->

      cb1 = sinon.spy()
      @paul.on ["a","b"], cb1

      @paul.emit "a", "foo"
      (expect cb1.callCount).toEqual 1

      @paul.emit "b", "bar"
      (expect cb1.callCount).toEqual 2

    it "subscribes several functions to several channels", ->

      cb1 = sinon.spy()
      cb2 = sinon.spy()
      @paul.on "a":cb1,"b":cb2

      @paul.emit "a", "foo"
      (expect cb1.callCount).toEqual 1
      (expect cb2.callCount).toEqual 0

      @paul.emit "b", "bar"
      (expect cb1.callCount).toEqual 1
      (expect cb2.callCount).toEqual 1

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
      (expect cb1.callCount).toEqual 1
      (expect cb2.callCount).toEqual 0

      sub2.attach()
      sub.detach()
      @paul.emit ch, "bar"
      (expect cb1.callCount).toEqual 1
      (expect cb2.callCount).toEqual 1

  describe "off function", ->

    it "removes a subscription from a channel", ->
      ch = "a channel"
      obj = {}
      cb1 = sinon.spy()
      cb2 = sinon.spy()

      @paul.on ch, cb1
      sub = @paul.on ch, cb2

      @paul.emit ch, "hello"
      @paul.off ch, cb1
      @paul.emit ch, "hello2"
      (expect cb1.callCount).toEqual 1
      (expect cb2.callCount).toEqual 2

    it "removes a callbackfunction from all channels", ->

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

      (expect cb1).not.toHaveBeenCalled()
      (expect cb2.callCount).toEqual 1

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

      (expect cb1.callCount).toEqual 4
      (expect cb2.callCount).toEqual 1

      obj.off()
      mediator.emit ch1, "hello"
      obj.emit ch1, "world"
      obj.emit ch2, "foo"

      (expect cb1.callCount).toEqual 6
      (expect cb2.callCount).toEqual 1

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

      (expect cb1.callCount).toEqual 4
      (expect cb2.callCount).toEqual 1

      obj.off ch2
      mediator.emit ch1, "hello"
      obj.emit ch1, "world"
      obj.emit ch2, "foo"

      (expect cb1.callCount).toEqual 8
      (expect cb2.callCount).toEqual 1

  describe "publish function", ->

    it "is an accessible function", ->
      (expect typeof @paul.emit).toEqual "function"

    it "has an alias method named 'emit'", ->
      (expect @paul.emit).toEqual @paul.emit

    it "returns the current context", ->
      (expect @paul.emit "my channel", {}).toEqual @paul
      (expect (new @Mediator).on "my channel", ->).not.toEqual @paul

    it "calls the callback if it is defined", (done) ->
      cb = sinon.spy()
      @paul.on "event", cb
      @paul.emit "event", {}, (err) ->
        (expect cb.callCount).toEqual 1
        done()

    it "calls the callback even if there are not subsribers", (done) ->
      m1 = new @Mediator
      m2 = new @Mediator
      m1.emit "x", (err)->
        (expect err?).toBe false
        m2.emit "x", "foo", (err)->
          (expect err?).toBe false
          done()

    it "passes an error if a callback returned false", (done) ->
      cb = sinon.spy()
      @paul.on "event", ->
        cb()
        false
      @paul.emit "event", {}, (err) ->
        (expect err).not.toBe null
        done()


    it "calls the callback asynchrounously", (done) ->
      cb  = sinon.spy()
      cb2 = sinon.spy()
      @paul.on "event", (data, channel, next) ->
        setTimeout (-> cb(); next null), 3
      @paul.on "event", (data, channel, x) ->
        setTimeout (-> cb2(); x null), 2
      @paul.emit "event", {}, (err) ->
        (expect cb.callCount).toEqual 1
        (expect cb2.callCount).toEqual 1
        (expect err?).toBe false
        done()

    it "calls the callback asynchrounously and looks for errors", (done) ->

      @paul.on "event", (data, channel, next) ->
        setTimeout (-> next null), 1
      @paul.on "event", (data, channel, x) ->
        setTimeout (-> x new Error "fake1"), 1
      @paul.on "event", (data, channel, x) ->
        x new Error "fake2"
      @paul.emit "event", {}, (err) ->
        (expect err.message).toEqual "fake1; fake2"
        done()

  describe "installTo function", ->

    it "is an accessible function", ->
      (expect typeof @paul.installTo).toEqual "function"

    it "installs the mediator functions", ->

      cb = sinon.spy()
      cb2 = sinon.spy()
      mediator = new @Mediator
      myObj = {}
      mediator.installTo myObj

      (expect typeof myObj.on).toEqual "function"
      (expect typeof myObj.on).toEqual "function"
      (expect typeof myObj.emit).toEqual "function"
      (expect typeof myObj.emit).toEqual "function"
      (expect typeof myObj.off).toEqual "function"
      (expect typeof myObj.channels).toEqual "object"

      myObj.on "ch", cb
      mediator.on "ch", cb2
      mediator.on "ch2", cb2

      myObj.emit "ch", "foo"
      mediator.emit "ch", "bar"
      mediator.emit "ch2", "blub"

      (expect cb.callCount).toEqual 2
      (expect cb2.callCount).toEqual 3

    it "takes care of the context", (done) ->
      mediator = new @Mediator
      myObj = {}
      empty = {}
      mediator.installTo myObj

      myObj.on "ch", -> (expect @).toEqual myObj
      mediator.on "ch", -> (expect @).toEqual mediator
      mediator.on "ch", (-> (expect @).toEqual empty), empty

      myObj.emit "ch", "foo"
      mediator.emit "ch", "bar"
      done()

    it "installs the mediator functions on creation", ->

      myObj = {}
      new @Mediator myObj
      (expect typeof myObj.on).toEqual "function"
      (expect typeof myObj.emit).toEqual "function"
      (expect typeof myObj.off).toEqual "function"
      (expect typeof myObj.channels).toEqual "object"

    it "returns the current context", ->
      (expect @paul.installTo {}).toEqual @paul
      (expect (new @Mediator).installTo {}).not.toBe @paul

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
      @paul.emit "doees not exist", @data
      (expect @cb.callCount).toEqual 2
      (expect @cb2).not.toHaveBeenCalled()

    it "publishes data to all subscribers even if an error occours", ->
      cb = sinon.spy()
      @paul.on "channel", -> cb()
      @paul.on "channel", -> (throw new Error "err"); cb()
      @paul.on "channel", -> cb()
      @paul.emit "channel"
      (expect cb.callCount).toEqual 2

    it "publishes a copy of data objects by default", (done) ->

      obj = {a:true,b:"x",c:{ y:0 }}
      arr = ["a",1,false]

      @paul.on "obj", (data) ->
        (expect data isnt obj).toBeTruthy()
        (expect data.b).toEqual obj.b

      @paul.on "obj-ref", (data) ->
        (expect data is obj).toBeTruthy()

      @paul.on "arr", (data) ->
        (expect data isnt arr).toBeTruthy()
        (expect data instanceof Array).toBeTruthy()

      @paul.on "arr-ref", (data) ->
        (expect data is arr).toBeTruthy()
        (expect data instanceof Array).toBeTruthy()

      @paul.emit "obj", obj
      @paul.emit "obj-ref", obj, emitReference: true
      @paul.emit "arr", arr
      @paul.emit "arr-ref", arr, emitReference: true
      done()

    it "does not publish data to other topics", ->

      @paul.on "a channel", @cb
      @paul.emit "another channel", @data
      (expect @cb).not.toHaveBeenCalled()

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
        # prcocess the query
        result = []
        for user in db
          result.push user for k,v of r.query when user[k] is v
        # send results
        r.receive null, result

      # receive a list of users by publishing a read event
      @dbAccess.emit "read",
        query: { role: "admin" }
        receive: (err, data) ->
          (expect data.length).toEqual 1
          (expect data[0]).toEqual { name: "markus", role: "admin" }
          done()

    describe "auto subscription", ->

      it "publishes subtopics to parent topics", ->

        @paul.cascadeChannels = true
        @paul.on "parentTopic", @cb
        @paul.on "parentTopic/subTopic", @cb1
        @paul.on "parentTopic/subTopic/subsub", @cb2
        @paul.on "parentTopic/otherSubTopic", @cb3

        @paul.emit "parentTopic/subTopic/subsub", @data
        (expect @cb).toHaveBeenCalled()
        (expect @cb1).toHaveBeenCalled()
        (expect @cb2).toHaveBeenCalled()
        (expect @cb3).not.toHaveBeenCalled()
