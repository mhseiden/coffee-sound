goog.provide "coffeesound.compiler.planner.opcodes.buffer"

goog.require "coffeesound.external.astjs"
goog.require "coffeesound.compiler.planner.utils"
goog.require "coffeesound.opcodes.buffers"

do ->
  SCRIPT_BUFFER_SIZE = 1024
  ASTJS = coffeesound.external.astjs
  { bindParam, bindValue, bindCallback } = coffeesound.compiler.planner.utils

###
  coffeesound.compiler.planner.opcodes.buffers.Strategy =
  class Strategy extends ASTJS.PlannerStrategy
    execute: (tree) ->
      buffers = coffeesound.opcodes.buffers
      if tree instanceof buffers.OneShotBuffer
        # buffer, trigger

      if tree instanceof buffers.LoopBuffer
        # buffer
###
