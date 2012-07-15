module.exports = ->
  global.buster = require "buster"
  global.sinon  = require "sinon"
  buster.spec.expose()
