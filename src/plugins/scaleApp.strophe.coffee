###
Copyright (c) 2012 - 2013 Markus Kohlhase <mail@markus-kohlhase.de>
###

throw new Error "This plugin only can be used in the browser" unless window?
console.warn "This plugin requires strophe.js" unless window.Strophe?

scaleApp = window.scaleApp

mediator = new scaleApp.Mediator

ID               = "xmpp"
DEFAULT_PATH     = "http-bind/"
DEFAULT_PROTOCOL = "http"
DEFAULT_PORT     = 5280
CACHE_PREFIX     = "scaleApp.#{ID}.cache."

# Variable that holds the Strophe connection object
connection = null

# Object that holds all connection sepecific options.
connection_options =
  host:     document.domain
  port:     DEFAULT_PORT
  path:     DEFAULT_PATH
  protocol: DEFAULT_PROTOCOL
  jid:      null
  sid:      null
  rid:      null

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
create_connection_obj = ->

  new Strophe.Connection get_bosh_url
    path:     connection_options.path
    host:     connection_options.host
    port:     connection_options.port
    protocol: connection_options.protocol

key2cache   = (k) -> "#{CACHE_PREFIX}#{k}"

saveData = ->
  if sessionStorage?
    for k in ["jid", "sid", "rid"] when connection[k]?
      sessionStorage[key2cache k] = connection[k]

    for k in ["host", "port", "path", "protocol"] when connection_options[k]?
      sessionStorage[key2cache k] = connection_options[k]

clearData = -> sessionStorage?.clear()

onConnected = ->

  # The BOSH connection get aborted by the escapae event.
  # Therefore we have to prevent it!

  fn       = (ev) -> ev.preventDefault?() if ev.keyCode is 27
  onunload = -> if connection then saveData() else clearData()

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
    when s.CONFAIL
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

resetPlugin = ->
  xmppPlugin.connection = null
  xmppPlugin.jid = ""

updatePlugin = (conn) ->
  xmppPlugin.connection = conn
  xmppPlugin.jid = conn.jid

# Attaches an existing connection to the Strophe connection object.
#
# Parameters:
# (Object) cookie - the cookie object that contains the connection properties
# like host, port, path, rid, sid and jid.
attach_connection = (opt) ->

  connection = create_connection_obj()
  connection.attach connection_options.jid
    , connection_options.sid
    , connection_options.rid
    , on_connection_change
    , 60

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

  connection = create_connection_obj()
  connection.connect jid, pw, on_connection_change

disconnect = ->

  console.debug "try to disconnect"

  if connection isnt null
    connection.send $pres(type: "unavailable")
    connection.pause()
    connection.disconnect()
  clearData()

# Converts a Jabber ID to an css friendly id.
#
# It replaces '.' and '@' with '-'.
#
# Parameters:
# (String) - Jabber ID
jid_to_id = (jid) ->
  Strophe.getBareJidFromJid(jid)
    .replace("@", "-")
    .replace(".", "-")
    .replace ".", "-"

# Loads the connection data from local storage.
restoreData = ->
  if sessionStorage?
    for k in [ "jid", "sid", "rid", "host", "port", "path", "protocol" ]
      j = key2cache k
      connection_options[k] = sessionStorage[j]  if sessionStorage[j]

hasConnectionData = ->
  opt = connection_options
  for k in [ "jid", "sid", "rid"  ]
    if not opt[k] or opt[k] is 'null' or opt[k] is 'undefined'
      return false
  true

init = ->
  restoreData()
  if hasConnectionData()
    attach_connection()
  else
    mediator.emit "disconnected"

# TODO: create core plugin
xmppPlugin =
  init:       init
  jid:        ""
  connection: null
  login:      login
  logout:     disconnect
  on:  -> mediator.on.apply mediator, arguments
  off: -> mediator.off.apply mediator, arguments

plugin =
  id: ID
  base:
    xmpp: xmppPlugin

scaleApp.plugin.register plugin if window?.scaleApp?
module.exports = plugin if module?.exports?
(define -> plugin) if define?.amd?
