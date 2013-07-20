require?("./nodeSetup")()

fs      = require 'fs'
sloc    = require "sloc"
zlib    = require "zlib"
buffer  = require "buffer"

getSlocOfFile = (file) ->
  sloc(fs.readFileSync(file, "utf8"), "coffeescript").sloc

describe "The codebase", ->

  it "has few lines of code", ->

    maxSLOC =
      "src/Core.coffee":      200
      "src/Mediator.coffee":  100
      "src/Util.coffee":      100
      "src/Sandbox.coffee":   50
      "src/scaleApp.coffee":  20

    sum = 0

    for file, count of maxSLOC
      x = getSlocOfFile file
      sum += x
      (expect x <= count).toBe true

    console.log sum
    (expect sum <= 350).toBe true

  it "is small", (done) ->
    stat = fs.statSync "dist/scaleApp.js"
    (expect stat.size <= 25000).toBe true
    stat = fs.statSync "dist/scaleApp.min.js"
    (expect stat.size <= 10000).toBe true
    min = fs.readFileSync "dist/scaleApp.min.js"
    b = new buffer.Buffer min
    zlib.gzip b, (err, compressed)->
      (expect compressed.length <= 3500).toBe true
      done()
