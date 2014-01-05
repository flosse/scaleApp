###
Copyright (c) 2012 - 2014 Markus Kohlhase <mail@markus-kohlhase.de>
###

DEFAULT_PATH     = "http-bind/"
DEFAULT_PROTOCOL = "http"
DEFAULT_PORT     = 5280

CACHE_PREFIX     = "scaleApp.xmpp.cache."

# Generates an appropriate bosh url for the connection.
#
# Parameters:
# (Object) opt - option object
get_bosh_url = (opt) ->

  domain = document.domain

  # there are 2^3 = 8 cases

  if typeof opt is "object"

    if opt.port
      opt.port = opt.port * 1
      if isNaN opt.port
        console.warn "the defined port #{ opt.port } is not a number."
        opt.port = null

    # case 1
    if opt.host and opt.port and opt.path
      return "#{ opt.protocol }://#{ opt.host }:#{ opt.port }/#{ opt.path }"

    # case 2
    if opt.host and opt.port and not opt.path
      return "#{ opt.protocol }://#{ opt.host }:#{ opt.port }/#{ DEFAULT_PATH }"

    # case 3
    if opt.host and not opt.port and opt.path
      return "#{ opt.protocol }://#{ opt.host }/#{ opt.path }"

    # case 4
    if opt.host and not opt.port and not opt.path
      return "#{ opt.protocol }://#{ opt.host }/#{ DEFAULT_PATH }"

    # case 5
    if not opt.host and opt.port and opt.path
      return "#{ opt.protocol }://#{ domain }:#{ opt.port }/#{ opt.path }"

    # case 6
    if not opt.host and opt.port and not opt.path
      return "#{ opt.protocol }://#{ domain }:#{ opt.port }/#{ DEFAULT_PATH }"

    # case 7
    if not opt.host and not opt.port and opt.path
      return "#{ opt.protocol }://#{ domain }/#{ opt.path }"

    # case 8
    if not opt.host and not opt.port and not opt.path
      return "#{ opt.protocol }://#{ domain }/#{ DEFAULT_PATH }"

  # fallback
  "http://#{ domain }/#{ DEFAULT_PATH }"

# Creates a new Strophe.Connection object with the appropriate options.
create_connection_obj = (opt) ->

  new Strophe.Connection get_bosh_url
    path:     opt.path
    host:     opt.host
    port:     opt.port
    protocol: opt.protocol

key2cache   = (k) -> "#{CACHE_PREFIX}#{k}"

saveData = (conn, opt)->
  return unless sessionStorage?
  for k in ["jid", "sid", "rid"] when conn[k]?
    sessionStorage[key2cache k] = conn[k]

  for k in ["host", "port", "path", "protocol"] when opt[k]?
    sessionStorage[key2cache k] = opt[k]

clearData = ->
  return unless sessionStorage?
  for k in ["jid", "sid", "rid", "host", "port", "path", "protocol"]
    sessionStorage.removeItem key2cache k

# Loads the connection data from session storage.
restoreData = ->
  return unless sessionStorage?
  o = {}
  for k in [ "jid", "sid", "rid", "host", "port", "path", "protocol" ]
    j = key2cache k
    o[k] = sessionStorage[j] if sessionStorage[j]

hasConnectionData = (opt) ->
  for k in [ "jid", "sid", "rid" ]
    if not opt[k] or opt[k] is 'null' or opt[k] is 'undefined'
      return false
  true

statusCodeToString = (s) ->
  switch s
    when 0 then "Error"
    when 1 then "Connecting"
    when 2 then "Connection failed"
    when 3 then "Authenticating"
    when 4 then "Authentication failed"
    when 5 then "Connected"
    when 6 then "Disconnected"
    when 7 then "Disconnecting"
    when 8 then "Reconnected"

plugin = (core) ->

  throw new Error "This plugin only can be used in the browser" unless window?
  console.warn "This plugin requires strophe.js" unless window.Strophe?

  mediator = new core.Mediator

  # Variable that holds the Strophe connection object
  connection = null

  resetPlugin = ->
    core.xmpp.connection = null
    core.xmpp.jid = ""

  updatePlugin = (conn) ->
    core.xmpp.connection = conn
    core.xmpp.jid = conn.jid

  onConnected = ->

    # The BOSH connection get aborted by the escapae event.
    # Therefore we have to prevent it!

    fn       = (ev) -> ev.preventDefault?() if ev.keyCode is 27
    onunload = ->
      if connection then saveData connection, connection_options
      else clearData()

    if document.addEventListener?
      for e in ["keydown", "keypress", "keyup"]
        document.addEventListener e, fn, false

      # Save connection properties before reloading the page.
      window.addEventListener "unload", onunload, false

    else if document.attachEvent?
      for e in ["onkeydown", "onkeypress", "onkeyup"]
        document.attachEvent e, fn

      # Save connection properties before reloading the page.
      document.attachEvent "onunload", onunload

    connection.send $pres()

  # Processes the Strophe connection staus.
  #
  # Parameters:
  # (int) status - The connection status code. See <Strophe.Status>
  on_connection_change = (status) ->

    console.info "xmpp status changed: " + statusCodeToString status

    s = Strophe.Status

    switch status

      when s.ERROR
        resetPlugin()
        mediator.emit "error", "an error occoured"
      when s.CONNECTING
        resetPlugin()
        mediator.emit "connecting"
      when s.CONNFAIL
        resetPlugin()
        mediator.emit "error", "could not connect to xmpp server"
      when s.AUTHENTICATING
        resetPlugin()
        mediator.emit "authenticating"
      when s.AUTHFAIL
        resetPlugin()
        mediator.emit "authfail"
      when s.CONNECTED
        updatePlugin connection
        onConnected()
        mediator.emit "connected"
      when s.DISCONNECTED
        clearData()
        resetPlugin()
        mediator.emit "disconnected"
      when s.DISCONNECTING
        resetPlugin()
        mediator.emit "disconnecting"
      when s.ATTACHED
        updatePlugin connection
        onConnected()
        mediator.emit "attached"

  # Attaches an existing connection to the Strophe connection object.
  #
  # Parameters:
  # (Object) cookie - the cookie object that contains the connection properties
  # like host, port, path, rid, sid and jid.
  attach_connection = (opt) ->

    connection = create_connection_obj opt
    connection.attach opt.jid, opt.sid, opt.rid, on_connection_change, 60

  connection_options = restoreData()

  if connection_options and hasConnectionData connection_options
    attach_connection connection_options
  else
    mediator.emit "disconnected"

    # Object that holds all connection sepecific options.
    connection_options =
      host:     document.domain
      port:     DEFAULT_PORT
      path:     DEFAULT_PATH
      protocol: DEFAULT_PROTOCOL
      jid:      null
      sid:      null
      rid:      null

  # Connects to the xmpp server and login with the given JID.
  #
  # Parameters:
  # (String) jid  - Jabber ID
  # (String) pw - Password
  # (Object) opt - Connection options.
  login = (jid, pw, opt) ->

    if opt?
      connection_options.path     = opt.path     if opt.path
      connection_options.port     = opt.port     if opt.port
      connection_options.host     = opt.host     if opt.host
      connection_options.protocol = opt.protocol if opt.protocol

    connection = create_connection_obj connection_options
    connection.connect jid, pw, on_connection_change

  disconnect = ->

    console.debug "try to disconnect"

    if connection?.connected is true
      try
        connection.send $pres type: "unavailable"
        connection.pause()
        connection.disconnect()
      catch e
    clearData()

  # public API
  core.xmpp =
    jid         : ""
    connection  : null
    login       : login
    logout      : disconnect
    on          : -> mediator.on.apply  mediator, arguments
    off         : -> mediator.off.apply mediator, arguments
    _mediator   : mediator

  null

# AMD support
if define?.amd?
  define -> plugin

# Browser support
else if window?.scaleApp?
  window.scaleApp.plugins.xmpp = plugin

# Node.js support
else if module?.exports?
  module.exports = plugin
