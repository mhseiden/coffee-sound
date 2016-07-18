goog.provide "coffeesound.expressions.data"

goog.require "coffeesound"
goog.require "coffeesound.expressions"

do ->
  KO = coffeesound.external.knockout

  { ExpressionTree, UnaryExpression, LeafExpression } = coffeesound.expressions
  { bindValue, bindComputed } = coffeesound.expressions

  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # Array Data Containers 
  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  class LazyArray
    fill: -> console.log("WARNING - fill is not defined for #{@}")
    constructor: (@buffer) ->
      Object.defineProperty @, "value",
        set: (v) => @buffer = v
        get: ( ) =>
          @fill(@buffer)
          return @buffer

  class DelegatedArray extends LeafExpression
    subscribe: -> throw new Error("cannot subscribe to changes from a DelegatedArray")

    constructor: (ctor,size,data) ->
      Object.defineProperty @, "value",
        set: (v) => @container().value = v
        get: ( ) => @container().value
      super(ctor,[size,new LazyArray(data)])

    size:      -> @args[0]
    container: -> @args[1]

  coffeesound.expressions.data.DelegatedByteArray =
  class DelegatedByteArray extends DelegatedArray
    constructor: (size = 0) ->
      super(DelegatedByteArray, size, new Uint8Array(size))

  coffeesound.expressions.data.DelegatedFloatArray =
  class DelegatedFloatArray extends DelegatedArray
    constructor: (size = 0) ->
      super(DelegatedFloatArray, size, new Float32Array(size))


  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # Audio Buffer Handling
  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  coffeesound.expressions.data.DecodedAudioBuffer =
  class DecodedAudioBuffer extends LeafExpression
    constructor: (buffer) ->
      bound = bindValue @, buffer
      super(DecodedAudioBuffer,[bound])

  coffeesound.expressions.data.EncodedAudioBuffer =
  class DecodedAudioBuffer extends LeafExpression
    constructor: (initial) ->
      @input = input = KO.observable()
      @output = output = KO.observable()

      @input.subscribe(@decode.bind(@,output))
      @input(initial)

      Object.defineProperty @, "value",
        set: (v) -> input(v)
        get: ( ) -> output()

    decode: (output,data) ->
      coffeesound._context.decodeAudioData(data)
        .then (buffer) -> output(buffer)

  coffeesound.expressions.data.SliceAudioBuffer =
  class SliceAudioBuffer extends UnaryExpression
    constructor: (buffer,start,end) ->
      bound = bindComputed @, -> SliceAudioBuffer.doSlice(buffer,start,end)
      super(SliceAudioBuffer,[buffer],[start,end,bound])

    start: -> @args[0]
    end: -> @args[1]

    @doSlice: (buffer,start,end) ->
      buffer = buffer.value
      start = start.value || 0.0
      end = end.value || 1.0

      # if there's no buffer, return straight away
      return null unless buffer?

      # compute the start and length of the actual buffer ([0..1] scale to [0..LEN] scale)
      start = start * buffer.length
      length = (end * buffer.length) - start

      channels = buffer.numberOfChannels
      target = coffeesound._context.createBuffer(channels,length,buffer.sampleRate)
      for c in [0...channels]
        dst = target.getChannelData(c)
        buffer.copyFromChannel(dst,c,start)
      return target
