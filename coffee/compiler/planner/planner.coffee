goog.provide "coffeesound.compiler.planner"

goog.require "coffeesound.external.astjs"
goog.require "coffeesound.compiler.planner.opcodes"

do ->
  ASTJS = coffeesound.external.astjs

  coffeesound.compiler.planner.Planner =
  class Planner extends ASTJS.Planner
    constructor: ->
      super([
        new coffeesound.compiler.planner.opcodes.OpcodeStrategy()
      ])

