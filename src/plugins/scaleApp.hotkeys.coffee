# Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)

# Function: hotkeys
# Binds a function to hotkeys.
# If an topic as string and data is used instead of the function 
# the data gets published.
# 
# Parameters:
# (String) keys       - The key combination 
# (Function) handler  - The handler function
# (String) type       - The event type 
hotkeys = (keys, handler, type, opt) ->

  # if user wants to publish s.th. directly
  if typeof handler is "string"

    # in this case 'handler' holds the topic, 'type' the data 
    # and 'opt' the type.
    opt = "keypress" if not opt

    $(document).bind opt, keys, -> sb.publish handler, type

  else if typeof handler is "function"
    type = "keypress" if not type
    $(document).bind type, keys, handler

scaleApp.registerPlugin "hotkeys", sandbox: -> hotkeys:hotkeys
