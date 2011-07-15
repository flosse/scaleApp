# Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)

# PrivateClass: scaleApp.mvc
#
# PrivateClass: observable
class Observable
  
  subscribe: (s) ->
    @_subscribers = []  unless @_subscribers
    @_subscribers.push s

  unsubscribe: (observer) ->

    if @_subscribers
      @_subscribers = @_subscribers.filter((el) ->
        el  if el != observer
      )

  notify: ->

    if @_subscribers
      $.each @_subscribers, (i, subscriber) ->
        if typeof subscriber["update"] is "function"
          subscriber["update"]()
        else subscriber()  if typeof subscriber is "function"

# Container for all models
models = {}

# Container for all views
views = {}

# Controller for all controllers
controllers = {}

# register function that gets called after an instance was created
onInstantiate = (instanceId, opt) ->

  if opt["models"]
    mixinDefaultModel opt["models"]
    addObjects models, instanceId, opt["models"]

  if opt["views"]
    addObjects views, instanceId, opt["views"]

  if opt["controllers"]
    addObjects controllers, instanceId, opt["controllers"]

# PrivateFunction: mixinDefaultModel
# Extend the model with standard model-methods by default.
# At the moment there are just the observale methods.
mixinDefaultModel = (objects) ->

  if typeof objects is "object"

    $.each objects, (i, obj) ->
      scaleApp.util.mixin obj, Observable if obj

#  PrivateFunction: addObjects
# 
#  Paraneters:
#  (Object) container
#  (String) instanceId
#  (Object) objects
addObjects = (container, instanceId, objects) ->

  if typeof objects is "object"
    $.each objects, (i, obj) ->
      add container, instanceId, i, obj  if obj

# PrivateFunction: add
# 
# Paraneters:
# (Object) container
# (String) instanceId
# (String) id
# (Object) obj
add = (container, instanceId, id, obj) ->

  container[instanceId] = {}  unless container[instanceId]
  container[instanceId][id] = obj

# PrivateFunction: get
#
# Paraneters:
# (Object) container
# (String) instanceId
# (String) id
get = (container, instanceId, id) ->

  o = container[instanceId]
  if o
    if not id and scaleApp.util.countObjectKeys(o) is 1
      for one of o
        break
      return o[one]
    o[id]

mvcPlugin = (sb, instanceId) ->

  # Function: getModel
  # Get a specific model.
  # 
  # Parameters:
  # (String) id - The model ID
  # 
  # Returns:
  # (Object) model  - The model object
  getModel = (id) -> get models, instanceId, id

  # Function: getView
  # Get a specific view.
  # 
  # Parameters:
  # (String) id - The view id
  # 
  # Returns:
  # (Object) view - The view object
  getView = (id) -> get views, instanceId, id

  
  # Function: getController
  # Get a specific controller.
  # 
  # Parameters:
  # (String) id   - The controller ID
  # 
  # Returns:
  # (Object) controller - The controller object
  getController = (id) -> get controllers, instanceId, id

  
  # Function: addModel
  # Add a model.
  # 
  # Paraneters:
  # (String) id     - The model ID
  # (Object) model  - The model object
  addModel = (id, model) -> add models, instanceId, id, view

  
  # Function: addView
  # Add a view.
  # 
  # Parameters:
  # (String) id    - The view ID
  # (Object) view  - The view object
  addView = (id, view) -> add views, instanceId, id, view

  # Function: addController
  # Add a controller.
  # 
  # Parameters:
  # (String) id         - The controller ID
  # (Object) controller - The controller object
  addController = (id, controller) -> add controllers, instanceId, id, controller

  'getModel': getModel
  'getView': getView
  'getController': getController
  'addModel': addModel
  'addView': addView
  'addController': addController
  'observable': Observable

corePlugin =
  'mvc':
    'observable': Observable

# register plugin
scaleApp.registerPlugin "mvc",
  sandbox: mvcPlugin
  core: corePlugin
  onInstantiate: onInstantiate
