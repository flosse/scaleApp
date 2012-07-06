class Mediator

  constructor: (obj) ->
    @channels = {}
    @installTo obj if obj

  # ## Subscribe to a topic
  #
  # Parameters:
  #
  # - (String) topic      - The topic name
  # - (Function) callback - The function that gets called if an other module
  #                         publishes to the specified topic
  # - (Object) context    - The context the function(s) belongs to
  subscribe: (channel, fn, context=@) ->

    @channels[channel] ?= []
    that = @

    if channel instanceof Array
      @subscribe id, fn, context for id in channel
    else if typeof channel is "object"
      @subscribe k,v,fn for k,v of channel
    else
      subscription = { context: context, callback: fn }
      (
        attach: -> that.channels[channel].push subscription; @
        detach: -> Mediator._rm that, channel, subscription.callback; @
      ).attach()

  # ## Unsubscribe from a topic
  #
  # Parameters:
  #
  # - (String) topic      - The topic name
  # - (Function) callback - The function that gets called if an other module
  #                         publishes to the specified topic
  unsubscribe: (ch, cb) ->
    switch typeof ch
      when "string"
        Mediator._rm @,ch,cb if typeof cb is "function"
        Mediator._rm @,ch    if typeof cb is "undefined"
      when "function"  then Mediator._rm @,id,ch      for id of @channels
      when "undefined" then Mediator._rm @,id         for id of @channels
      when "object"    then Mediator._rm @,id,null,ch for id of @channels
    @

  # ## Publish an event
  #
  # Parameters:
  # (String) topic             - The topic name
  # (Object) data              - The data that gets published
  # (Boolean) publishReference - If the data should be passed as a reference to
  #                              the other modules this parameter has to be set
  #                              to *true*.
  #                              By default the data object gets copied so that
  #                              other modules can't influence the original
  #                              object.
  publish: (channel, data, publishReference) ->

    if @channels[channel]?
      for subscription in @channels[channel]

        if publishReference isnt true and typeof data is "object"
          if data instanceof Array
            copy = (v for v in data)
          else
            copy = {}
            copy[k] = v for k,v of data
          try
            subscription.callback.apply subscription.context, [copy, channel]
          catch e
            console?.error? e

        else
          try
            subscription.callback.apply subscription.context, [data, channel]
          catch e
            console?.error? e
    @

  # ## Install Pub/Sub functions to an object
  installTo: (obj) ->
    if typeof obj is "object"
      obj[k] = v for k,v of @
    @

  @_rm: (o, ch, cb, ctxt) ->
    o.channels[ch] = (s for s in o.channels[ch] when (
      if cb?
        s.callback isnt cb
      else if ctxt?
        s.context isnt ctxt
      else
        s.context isnt o
    ))

module.exports = Mediator if module?.exports?
