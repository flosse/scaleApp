require?("./nodeSetup")()

fs      = require 'fs'
sloc    = require "sloc"
zlib    = require "zlib"
buffer  = require "buffer"

getSlocOfFile = (file) ->
  sloc(fs.readFileSync(file, "utf8"), "coffee").source

describe "The codebase", ->

  it "has few lines of code", ->

    maxSLOC =
      "src/Core.coffee"     : 160
      "src/Util.coffee"     : 100
      "src/Mediator.coffee" : 82
      "src/scaleApp.coffee" : 20

    sum = 0

    for file, count of maxSLOC
      x = getSlocOfFile file
      sum += x
      (expect x).to.be.at.most count

    console.log sum
    (expect sum).to.be.at.most 348

  it "is small", (done) ->
    stat = fs.statSync "dist/scaleApp.js"
    (expect stat.size).to.be.at.most 25000

    stat = fs.statSync "dist/scaleApp.min.js"
    (expect stat.size).to.be.at.most 10000

    min = fs.readFileSync "dist/scaleApp.min.js"
    b = new buffer.Buffer min
    zlib.gzip b, (err, compressed)->
      (expect compressed.length).to.be.at.most 3400
      done()
