goog.provide "coffeesound.compiler.planner.opcodes.buffers"

goog.require "coffeesound.external.astjs"
goog.require "coffeesound.compiler.planner.utils"
goog.require "coffeesound.opcodes.buffers"

do ->
  ASTJS = coffeesound.external.astjs
  { bindParam, bindValue, bindCallback } = coffeesound.compiler.planner.utils

  coffeesound.compiler.planner.opcodes.buffers.Strategy =
  class Strategy extends ASTJS.PlannerStrategy
    execute: (tree) ->
      context = coffeesound._context
      buffers = coffeesound.opcodes.buffers

      if tree instanceof buffers.OneShot
        # use a gain node to isolate source nodes from the tree
        gain = context.createGain()

        # TODO - track 'all' active so that we can easily cancel
        # all of the in-flight oneshots that are playing...doing
        # this will likely require a nice circular buffer impl :-)
        #
        # track the latest registered source node
        active = null

        tree.trigger().subscribe ->
          # cancel the last oneshot, depending on the args
          active.stop() if active? and yes == tree.cancel().value

          # only schedule playback if we have a value in hand
          if (buffer = tree.buffer().value)?
            src = active = context.createBufferSource()
            src.buffer = buffer
            src.connect(gain)
            src.start() # TODO - thread timestamps through the observer chain

            src.onended = ->
              src.disconnect()
              active = null if src == active # drop the ref if we're the latest

        return [gain]
