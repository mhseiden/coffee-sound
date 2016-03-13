goog.provide "coffeesound.compiler.planner"

goog.require "coffeesound.external.astjs"
ASTJS = coffeesound.external.astjs

goog.require "coffeesound.compiler.planner.opcodes"

do ->
  coffeesound.compiler.planner.Planner =
  class Planner extends ASTJS.Planner
    constructor: ->
      super([
        new coffeesound.compiler.planner.opcodes.OpcodeStrategy()
      ])

