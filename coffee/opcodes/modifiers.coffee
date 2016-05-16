goog.provide "coffeesound.opcodes.modifiers"

goog.require "coffeesound"
goog.require "coffeesound.opcodes"

do ->
  A_RATE = coffeesound.RATE.A_RATE

  coffeesound.opcodes.modifiers.DelayNode =
  class DelayNode extends coffeesound.opcodes.UnaryNode
    constructor: (child,delayTime) ->
      super(A_RATE,DelayNode,child,[delayTime])

    delayTime: -> @args[0]

  coffeesound.opcodes.modifiers.GainNode =
  class GainNode extends coffeesound.opcodes.UnaryNode
    constructor: (child,level) ->
      super(A_RATE,GainNode,child,[level])

    level: -> @args[0]
