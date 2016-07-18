goog.provide "coffeesound.opcodes.buffers"

goog.require "coffeesound"
goog.require "coffeesound.opcodes"

do ->
  A_RATE = coffeesound.RATE.A_RATE

  coffeesound.opcodes.buffers.OneShotBuffer =
  class OneShotBuffer extends coffeesound.opcodes.LeafNode
    constructor: (buffer,trigger) ->
      super(A_RATE,OneShotBuffer,[buffer,trigger])

    buffer: -> @args[0]
    trigger: -> @args[1]

  coffeesound.opcodes.buffers.LoopBuffer =
  class LoopBuffer extends coffeesound.opcodes.LeafNode
    constructor: (buffer,play) ->
      super(A_RATE,LoopBuffer,[buffer,play])

    buffer: -> @args[0]
    play: -> @args[1]
