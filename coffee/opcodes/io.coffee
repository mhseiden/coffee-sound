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
    constructor: (child,fftSize,smoothing,min,max,fBuffer,tBuffer,rate,state) ->
      args = [fftSize,smoothing,min,max,rate.fBuffer,tBuffer,rate,state]
      super(A_RATE,AnalyzerNode,child,args)

    fftSize:    -> @args[0]
    smoothing:  -> @args[1]
    min:        -> @args[2]
    max:        -> @args[3]
    fBuffer:    -> @args[5]
    tBuffer:    -> @args[6]
    rate:       -> @args[7]
    state:      -> @args[8]

  coffeesound.opcodes.io.ContextOutput =
  class ContextOutput extends coffeesound.opcodes.UnaryNode
    constructor: (child) ->
      super(A_RATE,ContextOutput,child,[])
