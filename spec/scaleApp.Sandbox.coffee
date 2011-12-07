describe "scaleApp Sanbox", ->

  beforeEach -> @sb = new scaleApp.Sandbox {}, "id"

  it "is an accessible function", ->
    (expect typeof scaleApp.Sandbox).toEqual "function"

  describe "constuctor", ->

    it "returns an object", ->
      (expect typeof new scaleApp.Sandbox {}, "myId").toEqual "object"

    it "throws an error if the core was not defined", ->
      (expect -> new scaleApp.Sandbox null, "an id").toThrow new Error "core was not defined"

    it "throws an error if no id was specified", ->
      (expect -> new scaleApp.Sandbox {}).toThrow new Error "no id was specified"

    it "throws an error if id is not a string", ->
      (expect -> new scaleApp.Sandbox {},{}).toThrow new Error "id is not a string"

    it "stores the instance id in 'instanceID'", ->

      sandbox = new scaleApp.Sandbox {}, "myId"
      (expect "myId").toEqual sandbox.instanceId

    it "has an empty object if no options were specified", ->
      (expect (new scaleApp.Sandbox {}, "myId").options).toEqual {}

    it "stores the option object", ->
      myOpts = { settingOne: "its boring" }
      (expect (new scaleApp.Sandbox {}, "myId", myOpts).options).toEqual myOpts
