goog.provide "coffeesound.compiler.planner.opcodes"

goog.require "coffeesound.compiler.planner.utils"
goog.require "coffeesound.opcodes.io"
goog.require "coffeesound.opcodes.math"
goog.require "coffeesound.opcodes.generators"
goog.require "coffeesound.expressions"
goog.require "coffeesound.external.astjs"

do ->
  SCRIPT_BUFFER_SIZE = 1024
  ASTJS = coffeesound.external.astjs
  { bindParam, bindValue, bindCallback } = coffeesound.compiler.planner.utils

  mkBinaryScriptProcessor = (tree,planner) ->
    context = coffeesound._context

    l = planner.planLater(tree.children[0])
    lSplit = context.createChannelSplitter(2)
    l.connect(lSplit)

    r = planner.planLater(tree.children[1])
    rSplit = context.createChannelSplitter(2)
    r.connect(rSplit)

    merger = context.createChannelMerger(4)

    # merge channel 0 from both nodes
    lSplit.connect(merger,0,0)
    rSplit.connect(merger,0,1)

    # merge channel 1 from both nodes
    lSplit.connect(merger,(if 2 == l.channelCount then 1 else 0),2)
    rSplit.connect(merger,(if 2 == r.channelCount then 1 else 0),3)

    processor = context.createScriptProcessor(SCRIPT_BUFFER_SIZE,4,2)
    merger.connect(processor)
    return processor

  # a function bound with a buffer size and binary arithmetic operation
  StereoBinaryProcessor = (bufferSize,op) -> (e) ->
    iBuffers = e.inputBuffer
    oBuffers = e.outputBuffer

    # pull out the left buffers
    i1Left = iBuffers.getChannelData(0)
    i2Left = iBuffers.getChannelData(1)
    oLeft = oBuffers.getChannelData(0)

    # pull out the right buffers
    i1Right = iBuffers.getChannelData(2)
    i2Right = iBuffers.getChannelData(3)
    oRight = oBuffers.getChannelData(1)

    # do a single pass over both buffers and scale down by 50%
    for i in [0...bufferSize] by 1
      oLeft[i]  = 0.5 * op(i1Left[i],i2Left[i])
      oRight[i] = 0.5 * op(i1Right[i],i2Right[i])
    return

  coffeesound.compiler.planner.opcodes.GeneratorStrategy =
  class GeneratorStrategy extends ASTJS.PlannerStrategy
    execute: (tree) ->
      context = coffeesound._context
      expr = coffeesound.expressions
      generators = coffeesound.opcodes.generators

      if tree instanceof generators.OscillatorNode
        osc = context.createOscillator()
        osc.channelCountMode = "explicit"
        osc.channelInterpretation = "speakers"
        osc.channelCount = 1

        bindParam tree, "freq", osc.frequency
        bindParam tree, "detune", osc.detune
        bindCallback tree, "waveform", (waveform) -> osc.type = waveform

        osc.start(0)
        return [osc]

  Add = (a,b) -> a+b
  Sub = (a,b) -> a-b
  Mul = (a,b) -> a*b
  Div = (a,b) -> if b == 0 then 0 else a/b

  coffeesound.compiler.planner.opcodes.MathStrategy =
  class MathStrategy extends ASTJS.PlannerStrategy
    execute: (tree) ->
      math = coffeesound.opcodes.math
      if tree instanceof math.Add
        node = mkBinaryScriptProcessor(tree,@planner)
        node.onaudioprocess = StereoBinaryProcessor(node.bufferSize,Add)
        return [node]

      if tree instanceof math.Mul
        node = mkBinaryScriptProcessor(tree,@planner)
        node.onaudioprocess = StereoBinaryProcessor(node.bufferSize,Mul)
        return [node]

      if tree instanceof math.Sub
        node = mkBinaryScriptProcessor(tree,@planner)
        node.onaudioprocess = StereoBinaryProcessor(node.bufferSize,Sub)
        return [node]

      if tree instanceof math.Div
        node = mkBinaryScriptProcessor(tree,@planner)
        node.onaudioprocess = StereoBinaryProcessor(node.bufferSize,Div)
        return [node]

  coffeesound.compiler.planner.opcodes.IOStrategy =
  class IOStrategy extends ASTJS.PlannerStrategy
    execute: (tree) ->
      context = coffeesound._context
      expr = coffeesound.expressions
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
        if fBuffer instanceof expr.DelegatedByteArray
          fBuffer.container().fill = (b) -> analyzer.getByteFrequencyData(b)
        else if fBuffer instanceof expr.DelegatedFloatArray
          fBuffer.container().fill = (b) -> analyzer.getFloatFrequencyData(b)

        tBuffer = tree.tBuffer()
        if tBuffer instanceof expr.DelegatedByteArray
          tBuffer.container().fill = (b) -> analyzer.getByteTimeDomainData(b)
        else if tBuffer instanceof expr.DelegatedFloatArray
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

  coffeesound.compiler.planner.opcodes.ModifierStrategy =
  class ModifierStrategy extends ASTJS.PlannerStrategy
    execute: (tree) ->
      context = coffeesound._context
      modifiers = coffeesound.opcodes.modifiers

      if tree instanceof modifiers.DelayNode
        input = @planner.planLater(tree.children[0])
        delay = context.createDelay(12.0)
        input.connect(delay)

        bindParam tree, "delayTime", delay.delayTime
        return [delay]

      if tree instanceof modifiers.GainNode
        input = @planner.planLater(tree.children[0])
        gain = context.createGain()
        input.connect(gain)

        bindParam tree, "level", gain.gain
        return [gain]
