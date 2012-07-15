require?("./nodeSetup")()

describe "Mediator", ->

  before ->
    if typeof(require) is "function"
      @Mediator = require "../src/Mediator"
    else if window?
      @Mediator = window.scaleApp.Mediator
    @paul = new @Mediator

  describe "subscribe function", ->

    it "is an accessible function", ->
      (expect typeof @paul.subscribe).toEqual "function"

    it "returns a subscription object", ->

      ch = "a channel"
      obj = {}
      cb1 = sinon.spy()
      cb2 = sinon.spy()

      sub = @paul.subscribe ch, cb1
      sub2 = @paul.subscribe ch, cb1, obj

      (expect typeof sub).toEqual "object"
      (expect typeof sub.attach).toEqual "function"
      (expect typeof sub.detach).toEqual "function"
      (expect sub).not.toEqual sub2

    it "subscribes a function to several channels", ->

      cb1 = sinon.spy()
      @paul.subscribe ["a","b"], cb1

      @paul.publish "a", "foo"
      (expect cb1.callCount).toEqual 1

      @paul.publish "b", "bar"
      (expect cb1.callCount).toEqual 2

    it "subscribes several functions to several channels", ->

      cb1 = sinon.spy()
      cb2 = sinon.spy()
      @paul.subscribe "a":cb1,"b":cb2

      @paul.publish "a", "foo"
      (expect cb1.callCount).toEqual 1
      (expect cb2.callCount).toEqual 0

      @paul.publish "b", "bar"
      (expect cb1.callCount).toEqual 1
      (expect cb2.callCount).toEqual 1

  describe "subscription object", ->

    it "can be detached and attached", ->

      ch = "channel"
      obj = {}
      cb1 = sinon.spy()
      cb2 = sinon.spy()
      sub = @paul.subscribe ch, cb1

      sub2 = @paul.subscribe ch, cb2, obj
      sub2.detach()
      @paul.publish ch, "foo"
      (expect cb1.callCount).toEqual 1
      (expect cb2.callCount).toEqual 0

      sub2.attach()
      sub.detach()
      @paul.publish ch, "bar"
      (expect cb1.callCount).toEqual 1
      (expect cb2.callCount).toEqual 1

  describe "unsubscribe function", ->

    it "removes a subscription from a channel", ->
      ch = "a channel"
      obj = {}
      cb1 = sinon.spy()
      cb2 = sinon.spy()

      @paul.subscribe ch, cb1
      sub = @paul.subscribe ch, cb2

      @paul.publish ch, "hello"
      @paul.unsubscribe ch, cb1
      @paul.publish ch, "hello2"
      (expect cb1.callCount).toEqual 1
      (expect cb2.callCount).toEqual 2

    it "removes a callbackfunction from all channels", ->

      ch1 = "channel1"
      ch2 = "channel2"
      cb1 = sinon.spy()
      cb2 = sinon.spy()

      @paul.subscribe ch1, cb1
      @paul.subscribe ch2, cb1, {}
      @paul.subscribe ch1, cb2

      @paul.unsubscribe cb1

      @paul.publish ch1, "hello"
      @paul.publish ch2, "hello"

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

      mediator.subscribe ch1, cb1
      obj.subscribe ch1, cb1
      obj.subscribe ch2, cb2

      mediator.publish ch1, "hello"
      obj.publish ch1, "world"
      obj.publish ch2, "foo"

      (expect cb1.callCount).toEqual 4
      (expect cb2.callCount).toEqual 1

      obj.unsubscribe()
      mediator.publish ch1, "hello"
      obj.publish ch1, "world"
      obj.publish ch2, "foo"

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

      mediator.subscribe ch1, cb1
      obj.subscribe ch1, cb1
      obj.subscribe ch2, cb2

      mediator.publish ch1, "hello"
      obj.publish ch1, "world"
      obj.publish ch2, "foo"

      (expect cb1.callCount).toEqual 4
      (expect cb2.callCount).toEqual 1

      obj.unsubscribe ch2
      mediator.publish ch1, "hello"
      obj.publish ch1, "world"
      obj.publish ch2, "foo"

      (expect cb1.callCount).toEqual 8
      (expect cb2.callCount).toEqual 1

  describe "publish function", ->

    it "is an accessible function", ->
      (expect typeof @paul.publish).toEqual "function"

    it "returns the current context", ->
      (expect @paul.publish "my channel", {}).toEqual @paul
      (expect (new @Mediator).subscribe "my channel", ->).not.toEqual @paul

  describe "installTo function", ->

    it "is an accessible function", ->
      (expect typeof @paul.installTo).toEqual "function"

    it "installs the mediator functions", ->

      cb = sinon.spy()
      cb2 = sinon.spy()
      mediator = new @Mediator
      myObj = {}
      mediator.installTo myObj

      (expect typeof myObj.subscribe).toEqual "function"
      (expect typeof myObj.publish).toEqual "function"
      (expect typeof myObj.unsubscribe).toEqual "function"
      (expect typeof myObj.channels).toEqual "object"

      myObj.subscribe "ch", cb
      mediator.subscribe "ch", cb2
      mediator.subscribe "ch2", cb2

      myObj.publish "ch", "foo"
      mediator.publish "ch", "bar"
      mediator.publish "ch2", "blub"

      (expect cb.callCount).toEqual 2
      (expect cb2.callCount).toEqual 3

    it "takes care of the context", (done) ->
      mediator = new @Mediator
      myObj = {}
      empty = {}
      mediator.installTo myObj

      myObj.subscribe "ch", -> (expect @).toEqual myObj
      mediator.subscribe "ch", -> (expect @).toEqual mediator
      mediator.subscribe "ch", (-> (expect @).toEqual empty), empty

      myObj.publish "ch", "foo"
      mediator.publish "ch", "bar"
      done()

    it "installs the mediator functions on creation", ->

      myObj = {}
      new @Mediator myObj
      (expect typeof myObj.subscribe).toEqual "function"
      (expect typeof myObj.publish).toEqual "function"
      (expect typeof myObj.unsubscribe).toEqual "function"
      (expect typeof myObj.channels).toEqual "object"

    it "returns the current context", ->
      (expect @paul.installTo {}).toEqual @paul
      (expect (new @Mediator).installTo {}).not.toBe @paul

  describe "Pub/Sub", ->

    beforeEach ->
      @peter = new @Mediator
      @data = { bla: "blub"}
      @cb = sinon.spy()
      @cb2 = sinon.spy()
      @cb3 = sinon.spy()
      @anObject = {}

    it "publishes data to a subscribed topic", ->

      @paul.subscribe  "a channel", @cb
      @paul.installTo @anObject
      @anObject.subscribe "a channel", @cb
      @peter.subscribe "a channel", @cb2
      @paul.publish "a channel", @data
      @paul.publish "doees not exist", @data
      (expect @cb.callCount).toEqual 2
      (expect @cb2).not.toHaveBeenCalled()

    it "publishes data to all subscribers even if an error occours", ->
      cb = sinon.spy()
      @paul.subscribe "channel", -> cb()
      @paul.subscribe "channel", -> (throw new Error "err"); cb()
      @paul.subscribe "channel", -> cb()
      @paul.publish "channel"
      (expect cb.callCount).toEqual 2

    it "publishes a copy of data objects by default", (done) ->

      obj = {a:true,b:"x",c:{ y:0 }}
      arr = ["a",1,false]

      @paul.subscribe "obj", (data) ->
        (expect data isnt obj).toBeTruthy()
        (expect data.b).toEqual obj.b

      @paul.subscribe "obj-ref", (data) ->
        (expect data is obj).toBeTruthy()

      @paul.subscribe "arr", (data) ->
        (expect data isnt arr).toBeTruthy()
        (expect data instanceof Array).toBeTruthy()

      @paul.subscribe "arr-ref", (data) ->
        (expect data is arr).toBeTruthy()
        (expect data instanceof Array).toBeTruthy()

      @paul.publish "obj", obj
      @paul.publish "obj-ref", obj, true
      @paul.publish "arr", arr
      @paul.publish "arr-ref", arr, true
      done()

    it "does not publish data to other topics", ->

      @paul.subscribe "a channel", @cb
      @paul.publish "another channel", @data
      (expect @cb).not.toHaveBeenCalled()

  describe "auto subscription", ->

      # ! NOT IMPLEMENTED !

    it "//publishes subtopics to parent topics", ->

      @paul.subscribe "parentTopic", @cb
      @peter.subscribe "parentTopic/subTopic", @cb2
      @peter.subscribe "parentTopic/otherSubTopic", @cb3

      @paul.publish "parentTopic/subTopic", @data
      (expect @cb).toHaveBeenCalled()
      (expect @cb2).toHaveBeenCalled()
      (expect @cb3).not.toHaveBennCalled()
