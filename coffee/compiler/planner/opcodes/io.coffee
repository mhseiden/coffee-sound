goog.provide "coffeesound.compiler.planner.opcodes.io"

goog.require "coffeesound.external.astjs"
goog.require "coffeesound.compiler.planner.utils"
goog.require "coffeesound.opcodes.io"
goog.require "coffeesound.expressions.data"

do ->
  ASTJS = coffeesound.external.astjs
  { bindParam, bindValue, bindCallback } = coffeesound.compiler.planner.utils

  coffeesound.compiler.planner.opcodes.io.Strategy =
  class Strategy extends ASTJS.PlannerStrategy
    execute: (tree) ->
      context = coffeesound._context
      data = coffeesound.expressions.data
      io = coffeesound.opcodes.io

      if tree instanceof io.URLStreamInput
        audio = new Audio()
        audio.crossOrigin = "anonymous"
        bindValue tree, "src", audio
        bindCallback tree, "play", (state) -> if on == state then audio.play() else audio.pause()
        return [context.createMediaElementSource(audio)]

      # (max) TODO - add the "active" node to mute the mic
      if tree instanceof io.MicrophoneInput
        microphone = coffeesound._microphone
        source = context.createMediaStreamSource(microphone)
        return [source]
        

      if tree instanceof io.ContextOutput
        input = @planner.planLater(tree.children[0])
        input.connect(context.destination)

        return [context.destination]

      if tree instanceof io.AnalyzerNode
        input = @planner.planLater(tree.children[0])
        analyzer = context.createAnalyser()
        input.connect(analyzer)

        bindValue tree, "fftSize", analyzer
        bindValue tree, "smoothing", analyzer, "smoothingTimeConstant"
        bindValue tree, "min", analyzer, "minDecibels"
        bindValue tree, "max", analyzer, "maxDecibels"

        # (max) XXX - the spec doesn't seem to have any details on whether
        # calls to getTimeDomainData and getFrequencyData - in the same event
        # loop iteration - consider the same raw sample range, or use the
        # current context time when the call occurs when determining that
        # range...as such this API also does not specify any particular
        # behavior beyond that of the underlying WebAudio implementation...
        fBuffer = tree.fBuffer()
        if fBuffer instanceof data.DelegatedByteArray
          fBuffer.container().fill = (b) -> analyzer.getByteFrequencyData(b)
        else if fBuffer instanceof data.DelegatedFloatArray
          fBuffer.container().fill = (b) -> analyzer.getFloatFrequencyData(b)

        tBuffer = tree.tBuffer()
        if tBuffer instanceof data.DelegatedByteArray
          tBuffer.container().fill = (b) -> analyzer.getByteTimeDomainData(b)
        else if tBuffer instanceof data.DelegatedFloatArray
          tBuffer.container().fill = (b) -> analyzer.getFloatTimeDomainData(b)

        return [analyzer]

      if tree instanceof io.ExtractChannel
        input = @planner.planLater(tree.children[0])
        splitter = context.createChannelSplitter(input.channelCount)
        merger = context.createChannelMerger(1)

        input.connect(splitter)
        bindCallback tree, "index", (index) -> splitter.connect(merger,index,0)
        return [merger]

      if tree instanceof io.StereoStreamConstructor
        l = @planner.planLater(tree.children[0])
        r = @planner.planLater(tree.children[1])

        merger = context.createChannelMerger(2)
        l.connect(merger,0,0)
        r.connect(merger,0,1)
        return [merger]
