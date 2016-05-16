goog.provide "coffeesound.compiler.planner.opcodes.modifiers"

goog.require "coffeesound.external.astjs"
goog.require "coffeesound.compiler.planner.utils"
goog.require "coffeesound.opcodes.modifiers"

do ->
  ASTJS = coffeesound.external.astjs
  { bindParam, bindValue, bindCallback } = coffeesound.compiler.planner.utils

  coffeesound.compiler.planner.opcodes.modifiers.Strategy =
  class Strategy extends ASTJS.PlannerStrategy
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
