goog.provide "coffeesound.opcodes.io"

goog.require "coffeesound"
goog.require "coffeesound.opcodes"

A_RATE = coffeesound.RATE.A_RATE

coffeesound.opcodes.io.URLStreamInput =
class URLStreamInput extends coffeesound.opcodes.LeafNode
  constructor: (src,play) ->
    args = [src,play]
    super(A_RATE,URLStreamInput,args)

  src:  -> @args[0]
  play: -> @args[1]

coffeesound.opcodes.io.ContextOutput =
class ContextOutput extends coffeesound.opcodes.UnaryNode
  constructor: (child) ->
    super(A_RATE,ContextOutput,child,[])
