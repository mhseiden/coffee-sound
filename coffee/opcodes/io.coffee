goog.provide "coffeesound.opcodes.io"

goog.require "coffeesound"
goog.require "coffeesound.opcodes"

do ->
  A_RATE = coffeesound.RATE.A_RATE

  coffeesound.opcodes.io.AudioBufferInput =
  class AudioBufferInput extends coffeesound.opcodes.LeafNode
    constructor: (buffer,detune,loopOn,loopStart,loopEnd,playbackRate) ->
      super(A_RATE,AudioBufferInput,[buffer])

  coffeesound.opcodes.io.URLStreamInput =
  class URLStreamInput extends coffeesound.opcodes.LeafNode
    constructor: (src,play) ->
      args = [src,play]
      super(A_RATE,URLStreamInput,args)

    src:  -> @args[0]
    play: -> @args[1]

  coffeesound.opcodes.io.MicrophoneInput =
  class MicrophoneInput extends coffeesound.opcodes.LeafNode
    constructor: (active) ->
      super(A_RATE,MicrophoneInput,[active])

    active: -> @args[0]

  coffeesound.opcodes.io.AnalyzerNode =
  class AnalyzerNode extends coffeesound.opcodes.UnaryNode
    constructor: (child, fBuffer, tBuffer, fftSize = 2048, smoothing = 0.8, min = -100, max = -30) ->
      fBuffer = [] unless fBuffer?
      tBuffer = [] unless tBuffer?
      args = [fftSize,smoothing,min,max,fBuffer,tBuffer]
      super(A_RATE,AnalyzerNode,child,args)

    fftSize:    -> @args[0]
    smoothing:  -> @args[1]
    min:        -> @args[2]
    max:        -> @args[3]
    fBuffer:    -> @args[4]
    tBuffer:    -> @args[5]

  coffeesound.opcodes.io.ContextOutput =
  class ContextOutput extends coffeesound.opcodes.UnaryNode
    constructor: (child) ->
      super(A_RATE,ContextOutput,child,[])

  coffeesound.opcodes.io.ExtractChannel =
  class ExtractChannel extends coffeesound.opcodes.UnaryNode
    constructor: (child,index) ->
      super(A_RATE,ExtractChannel,child,[index])

    index: -> @args[0]

  coffeesound.opcodes.io.StereoStreamConstructor =
  class StereoStreamConstructor extends coffeesound.opcodes.BinaryNode
    constructor: (left,right) ->
      super(A_RATE,StereoStreamConstructor,left,right,[])
