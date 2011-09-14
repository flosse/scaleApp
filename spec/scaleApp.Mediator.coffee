describe "Mediator", ->

  beforeEach ->
    @paul = new scaleApp.Mediator "paul"

  describe "constructor", ->

    it "creates a new mediator object with its name", ->
      (expect @paul.name).toEqual "paul"

    it "has an empty string as name if no one was defined", ->
      (expect (new scaleApp.Mediator).name).toEqual ""

  describe "subscribe function", ->

    it "is an accessible function", ->
      (expect typeof @paul.subscribe).toEqual "function"

    it "returns the current context", ->
      (expect @paul.subscribe "my channel", -> ).toEqual @paul
      (expect (new scaleApp.Mediator "peter").subscribe "my channel", -> ).toNotEqual @paul

  describe "unsubscribe function", ->

    it "is an accessible function", ->
      (expect typeof @paul.unsubscribe).toEqual "function"

    it "returns the current context", ->
      (expect @paul.unsubscribe "my channel" ).toEqual @paul
      (expect (new scaleApp.Mediator "peter").unsubscribe "my channel" ).toNotEqual @paul

  describe "publish function", ->

    it "is an accessible function", ->
      (expect typeof @paul.publish).toEqual "function"

    it "returns the current context", ->
      (expect @paul.publish "my channel", {}).toEqual @paul
      (expect (new scaleApp.Mediator "peter").subscribe "my channel", -> ).toNotEqual @paul

  describe "installTo function", ->

    it "is an accessible function", ->
      (expect typeof @paul.installTo).toEqual "function"

    it "install the subscribe and publish functions", ->
      myObj = {}
      @paul.installTo myObj
      (expect typeof myObj.subscribe).toEqual "function"
      (expect typeof myObj.publish).toEqual "function"

    it "returns the current context", ->
      (expect @paul.installTo "my channel", {}).toEqual @paul
      (expect (new scaleApp.Mediator "peter").installTo "my channel", -> ).toNotEqual @paul

  describe "Pub/Sub", ->

    beforeEach ->
      @peter = new scaleApp.Mediator "peter"
      @data = { bla: "blub"}
      @cb = jasmine.createSpy()
      @cb2 = jasmine.createSpy()
      @cb3 = jasmine.createSpy()
      @anObject = {}

    it "publishes data to a subscribed topic", ->
      @paul.subscribe  "a channel", @cb
      @peter.subscribe "a channel", @cb2
      @paul.publish "a channel", @data
      (expect @cb).toHaveBeenCalled()
      (expect @cb2).wasNotCalled()

    it "does not publish data to other topics", ->

      @paul.subscribe "a channel", @cb
      @paul.publish "another channel", @data
      (expect @cb).wasNotCalled()

    describe "auto subscription", ->

      # ! NOT IMPLEMENTED !
      
      # it "publishes subtopics to parent topics", ->

      #   @paul.subscribe  "parentTopic", @cb
      #   @peter.subscribe  "parentTopic/subTopic", @cb2
      #   @peter.subscribe  "parentTopic/otherSubTopic", @cb3

      #   @paul.publish "parentTopic/subTopic", @data
      #   (expect @cb).toHaveBeenCalled()
      #   (expect @cb2).toHaveBeenCalled()
      #   (expect @cb3).wasNotCalled()
