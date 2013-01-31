class Mediator

  constructor: (obj, @cascadeChannels=false) ->
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
  on: (channel, fn, context=@) ->

    @channels[channel] ?= []
    that = @

    if channel instanceof Array
      @on id, fn, context for id in channel
    else if typeof channel is "object"
      @on k,v,fn for k,v of channel
    else
      return false unless typeof fn      is "function"
      return false unless typeof channel is "string"
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
  off: (ch, cb) ->
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
  # (Funtction)                - callback method
  emit: (channel, data, cb=->) ->

    if typeof data is "function"
      cb  = data
      data = undefined
    return false unless typeof channel is "string"
    subscribers = @channels[channel] or []

    tasks = for sub in subscribers then do (sub) ->
      (next) ->
        try
          if (util.getArgumentNames sub.callback).length >= 3
            sub.callback.apply sub.context, [data, channel, next]
          else
            next null, sub.callback.apply sub.context, [data, channel]
        catch e
          next e

    util.runSeries tasks,((errors, results) ->
      if errors
        e = new Error (x.message for x in errors when x?).join '; '
      cb e), true

    if @cascadeChannels and (chnls = channel.split('/')).length > 1
      @emit chnls[0...-1].join('/'), data, cb
    @

  # ## Install Pub/Sub functions to an object
  installTo: (obj) ->
    if typeof obj is "object"
      obj[k] = v for k,v of @
    @

  @_rm: (o, ch, cb, ctxt) ->
    return unless o.channels[ch]?
    o.channels[ch] = (s for s in o.channels[ch] when (
      if cb?
        s.callback isnt cb
      else if ctxt?
        s.context isnt ctxt
      else
        s.context isnt o
    ))
