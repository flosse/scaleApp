# export public API
api =

  # current version
  VERSION: "0.4.3"

  util: util

  # the mediator class
  Mediator: Mediator

  # the core class
  Core: Core

  # container for available plugins
  plugins: {}

  # container for available modules
  modules: {}

# support AMD
if define?.amd?
  define -> api

# support the browser
else if window?
  window.scaleApp ?= api

# support commonJS
else if module?.exports?
  module.exports = api
