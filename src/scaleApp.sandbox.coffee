# Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)
scaleApp["sandbox"] = (instanceId, opt) ->

  # Function: subscribe
  # Subscribe to a topic.
  #
  # Parameters:
  # (String) topic      - The topic name
  # (Function) callback - The function that gets called if an other module 
  #                       publishes to the specified topic 
  subscribe = (topic, callback) -> scaleApp.subscribe instanceId, topic, callback
  
  # Function: unsubscribe
  # Unsubscribe from a topic
  # 
  # Parameters:
  # (String) topic  - The topic name
  unsubscribe = (topic) -> scaleApp["unsubscribe"] instanceId, topic
  
  # Function: publish
  # Publish an event.
  # 
  # Parameters:
  # (String) topic             - The topic name
  # (Object) data              - The data you want to publish
  # (Boolean) publishReference - If the data should be passed as a reference to
  #                              the other modules this parameter has to be set
  #                              to *true*. 
  #                              By default the data object gets copied so that
  #                              other modules can't influence the original 
  #                              object. 
  publish = (topic, data, publishReference) ->
    scaleApp["publish"] topic, data, publishReference
  
  # Function: startSubModule
  # Start a submodule.
  #
  # Parameters:
  # (String) moduleId       - The module ID
  # (String) subInstanceId  - The subinstance ID
  # (Object) opt            - The option object
  # (Function) fn           - Callback function
  startSubModule = (moduleId, subInstanceId, opt, fn) ->
    scaleApp["startSubModule"] moduleId, subInstanceId, opt, instanceId, fn
  
  # Function: stopSubModule
  # Stop a submodule.
  #
  # Parameters:
  # (String) instanceId - The instance ID
  stopSubModule = (instanceId) -> scaleApp["stop"] instanceId
  
  # Function: getContainer
  # Get the DOM container of the module. 
  # 
  # Returns:
  # (Object) container - The container
  getContainer = -> scaleApp["getContainer"] instanceId
  
  'subscribe': subscribe
  'unsubscribe': unsubscribe
  'publish': publish
  'startSubModule': startSubModule
  'stopSubModule': stopSubModule
  'getContainer': getContainer
  'mixin': scaleApp["util"]["mixin"]
  'count': scaleApp["util"]["countObjectKeys"]
