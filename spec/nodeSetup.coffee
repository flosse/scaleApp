module.exports = ->
  global.sinon  = require "sinon"
  global.chai   = require "chai"
  global.expect = global.chai.expect

  global.chai.use require "sinon-chai"

  # workaround to solve cache problems
  get = global._require = (name) ->
    delete require.cache[require.resolve name]
    require name

  global.getScaleApp = ->
    get "../dist/scaleApp"
