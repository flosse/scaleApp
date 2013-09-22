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
      "src/Core.coffee":      160
      "src/Util.coffee":      80
      "src/Mediator.coffee":  70
      "src/scaleApp.coffee":  20

    sum = 0

    for file, count of maxSLOC
      x = getSlocOfFile file
      sum += x
      (expect x <= count).to.be.true

    console.log sum
    (expect sum <= 320).to.be.true

  it "is small", (done) ->
    stat = fs.statSync "dist/scaleApp.js"
    (expect stat.size <= 25000).to.be.true
    stat = fs.statSync "dist/scaleApp.min.js"
    (expect stat.size <= 10000).to.be.true
    min = fs.readFileSync "dist/scaleApp.min.js"
    b = new buffer.Buffer min
    zlib.gzip b, (err, compressed)->
      (expect compressed.length <= 3400).to.be.true
      done()
