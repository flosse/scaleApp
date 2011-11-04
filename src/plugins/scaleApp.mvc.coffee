class Model extends scaleApp.Mediator

  @reservedKeywords: ["set","get"]

  constructor: (obj) ->
    super()
    @id = obj?.id or scaleApp.uniqueId()
    @[k] = v for k,v of obj when not @[k]?

  set: (key, val) ->
    if typeof key is "object"
      @set k,v for k,v of key
    else
      if not (key in Model.reservedKeywords)
        if @[key] isnt val
          @[key] = val
          @publish "changed"
      @

  get: (key) -> @[key]

  toJSON: ->
    json = {}
    json[k]=v for k,v of @ when @hasOwnProperty k
    json

class View

  constructor: (model) -> @setModel model if model

  setModel: (@model) -> @model.subscribe "changed", => @render()

  render: ->

class Controller

  constructor: (@model, @view) ->

scaleApp.registerPlugin
  id: "mvc"
  core:
    Model: Model
    View: View
    Controller: Controller
