goog.provide "coffeesound.opcodes.generators"

goog.require "coffeesound"
goog.require "coffeesound.opcodes"

do ->
  A_RATE = coffeesound.RATE.A_RATE

  coffeesound.opcodes.generators.OscillatorNode =
  class OscillatorNode extends coffeesound.opcodes.LeafNode
    nodeName: -> "Oscillator"
    constructor: (freq,detune,waveform) ->
      args = [freq,detune,waveform]
      super(A_RATE,OscillatorNode,args)

    freq:     -> @args[0]
    detune:   -> @args[1]
    waveform: -> @args[2]
