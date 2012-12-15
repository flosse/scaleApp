module.exports = ->
  global.buster = require "buster"
  global.sinon  = require "sinon"
  buster.spec.expose()

  # workaround to solve cache problems
  get = global._require = (name) ->
    delete require.cache[require.resolve name]
    require name

  global.getScaleApp = ->
    get "../dist/scaleApp"
