goog.provide "coffeesound.opcodes.io"

goog.require "coffeesound"
goog.require "coffeesound.opcodes"

do ->
  A_RATE = coffeesound.RATE.A_RATE

  coffeesound.opcodes.io.URLStreamInput =
  class URLStreamInput extends coffeesound.opcodes.LeafNode
    constructor: (src,play) ->
      args = [src,play]
      super(A_RATE,URLStreamInput,args)

    src:  -> @args[0]
    play: -> @args[1]

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
