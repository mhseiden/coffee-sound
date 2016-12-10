goog.provide "coffeesound.opcodes.modifiers"

goog.require "coffeesound"
goog.require "coffeesound.opcodes"

do ->
  A_RATE = coffeesound.RATE.A_RATE

  coffeesound.opcodes.modifiers.DelayNode =
  class DelayNode extends coffeesound.opcodes.UnaryNode
    nodeName: -> "Delay"
    constructor: (child,delayTime) ->
      super(A_RATE,DelayNode,child,[delayTime])

    delayTime: -> @args[0]

  coffeesound.opcodes.modifiers.GainNode =
  class GainNode extends coffeesound.opcodes.UnaryNode
    nodeName: -> "Gain"
    constructor: (child,level) ->
      super(A_RATE,GainNode,child,[level])

    level: -> @args[0]

  coffeesound.opcodes.modifiers.BasicEnvelope =
  class BasicEnvelope extends coffeesound.opcodes.LeafNode
    nodeName: -> "Envelope"
    constructor: (t,a,d,s,r,min,max) ->
      super(A_RATE,BasicEnvelope,[t,a,d,s,r,min,max])

    trigger: -> @args[0]
    attack: -> @args[1]
    decay: -> @args[2]
    sustain: -> @args[3]
    release: -> @args[4]
    minValue: -> @args[5]
    maxValue: -> @args[6]
