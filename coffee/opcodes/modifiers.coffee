goog.provide "coffeesound.opcodes.modifiers"

goog.require "coffeesound"
goog.require "coffeesound.opcodes"

A_RATE = coffeesound.RATE.A_RATE

coffeesound.opcodes.modifiers.GainNode =
class GainNode extends coffeesound.opcodes.UnaryNode
  constructor: (child,level) ->
    super(A_RATE,GainNode,child,[level])
