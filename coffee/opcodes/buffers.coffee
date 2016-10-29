goog.provide "coffeesound.opcodes.buffers"

goog.require "coffeesound"
goog.require "coffeesound.opcodes"

do ->
  A_RATE = coffeesound.RATE.A_RATE

  coffeesound.opcodes.buffers.OneShot =
  class OneShot extends coffeesound.opcodes.LeafNode
    constructor: (buffer,trigger,cancel) ->
      super(A_RATE,OneShot,[buffer,trigger,cancel||true])

    buffer: -> @args[0]
    trigger: -> @args[1]
    cancel: -> @args[2]
