goog.provide "coffeesound.compiler.planner.opcodes.generators"

goog.require "coffeesound.external.astjs"
goog.require "coffeesound.compiler.planner.utils"
goog.require "coffeesound.opcodes.generators"

do ->
  ASTJS = coffeesound.external.astjs
  { bindParam, bindValue, bindCallback } = coffeesound.compiler.planner.utils

  coffeesound.compiler.planner.opcodes.generators.Strategy =
  class Strategy extends ASTJS.PlannerStrategy
    execute: (tree) ->
      context = coffeesound._context
      generators = coffeesound.opcodes.generators

      if tree instanceof generators.OscillatorNode
        osc = context.createOscillator()
        osc.channelCountMode = "explicit"
        osc.channelInterpretation = "speakers"
        osc.channelCount = 1

        bindParam tree, "freq", osc.frequency, @planner
        bindParam tree, "detune", osc.detune, @planner
        bindCallback tree, "waveform", (waveform) -> osc.type = waveform

        osc.start(0)
        return [osc]
