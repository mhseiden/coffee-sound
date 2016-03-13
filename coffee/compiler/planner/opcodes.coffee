goog.provide "coffeesound.compiler.planner.opcodes"

goog.require "coffeesound.compiler.planner.utils"
goog.require "coffeesound.opcodes.io"
goog.require "coffeesound.external.astjs"
ASTJS = coffeesound.external.astjs


do ->
  { bindValue, bindCallback } = coffeesound.compiler.planner.utils

  IOStrategy = (tree) ->
    context = coffeesound._context
    io = coffeesound.opcodes.io

    if tree instanceof io.URLStreamInput
      audio = new Audio()
      bindValue tree, "src", audio
      bindCallback tree, "play", (state) -> if on == state then audio.play() else audio.pause()
      return [context.createMediaElementSource(audio)]

    return []


  coffeesound.compiler.planner.opcodes.OpcodeStrategy =
  class OpcodeStrategy extends ASTJS.PlannerStrategy
    constructor: ->
      super()
      @strategies = [IOStrategy]

    execute: (tree) ->
      for strategy in @strategies
        planned = strategy(tree)
        return planned if planned?
