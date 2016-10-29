goog.provide "coffeesound.compiler.planner"

goog.require "coffeesound.external.astjs"
goog.require "coffeesound.compiler.planner.opcodes.io"
goog.require "coffeesound.compiler.planner.opcodes.generators"
goog.require "coffeesound.compiler.planner.opcodes.math"
goog.require "coffeesound.compiler.planner.opcodes.modifiers"

do ->
  ASTJS = coffeesound.external.astjs
  opcodes = coffeesound.compiler.planner.opcodes

  coffeesound.compiler.planner.Planner =
  class Planner extends ASTJS.Planner
    constructor: (extra = []) ->
      builtin = [
        new opcodes.buffers.Strategy(),
        new opcodes.io.Strategy(),
        new opcodes.generators.Strategy(),
        new opcodes.math.Strategy(),
        new opcodes.modifiers.Strategy()]

      super(extra.concat(builtin))

