goog.provide "coffeesound.compiler.planner.opcodes"

goog.require "coffeesound.compiler.planner.utils"
goog.require "coffeesound.opcodes.io"
goog.require "coffeesound.expressions"
goog.require "coffeesound.external.astjs"

do ->
  ASTJS = coffeesound.external.astjs
  { bindParam, bindValue, bindCallback } = coffeesound.compiler.planner.utils

  IOStrategy = (tree) ->
    context = coffeesound._context
    expr = coffeesound.expressions
    io = coffeesound.opcodes.io

    if tree instanceof io.URLStreamInput
      audio = new Audio()
      bindValue tree, "src", audio
      bindCallback tree, "play", (state) -> if on == state then audio.play() else audio.pause()
      return [context.createMediaElementSource(audio)]

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

  ModifierStrategy = (tree) ->
    context = coffeesound._context
    modifiers = coffeesound.opcodes.modifiers

    if tree instanceof modifiers.GainNode
      input = @planner.planLater(tree.children[0])
      gain = context.createGain()
      input.connect(gain)

      bindParam tree, "level", gain.gain
      return [gain]

  coffeesound.compiler.planner.opcodes.OpcodeStrategy =
  class OpcodeStrategy extends ASTJS.PlannerStrategy
    constructor: ->
      super()
      @strategies = [IOStrategy,ModifierStrategy]

    execute: (tree) ->
      for strategy in @strategies
        planned = strategy(tree)
        return planned if planned?
