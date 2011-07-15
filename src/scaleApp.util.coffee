# Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)

# PrivateFunction: mixin
mixin = (receivingClass, givingClass, override ) ->

  mix = (giv, rec) ->
    empty = {}
    if override is true
      $.extend rec, giv
    else
      $.extend empty, giv, rec
      $.extend rec, empty

  switch typeof givingClass + "-" + typeof receivingClass
    when "function-function"
      mix givingClass::, receivingClass::
    when "function-object"
      mix givingClass::, receivingClass
    when "object-object"
      mix givingClass, receivingClass
    when "object-function"
      mix givingClass, receivingClass::

# PrivateFunction: countObjectKeys
# Counts all available keys of an object.
countObjectKeys = (obj) ->
  count = 0
  if typeof obj is "object"
    for i of obj
      count++
  count

scaleApp['util'] =
  'mixin': mixin
  'countObjectKeys': countObjectKeys
