goog.provide "coffeesound.compiler.planner"

goog.require "coffeesound.external.astjs"
goog.require "coffeesound.compiler.planner.opcodes"

do ->
  ASTJS = coffeesound.external.astjs
  opcodes = coffeesound.compiler.planner.opcodes

  coffeesound.compiler.planner.Planner =
  class Planner extends ASTJS.Planner
    constructor: (extra = []) ->
      builtin = [
        new opcodes.IOStrategy(),
        new opcodes.GeneratorStrategy(),
        new opcodes.MathStrategy(),
        new opcodes.ModifierStrategy()]

      super(extra.concat(builtin))

