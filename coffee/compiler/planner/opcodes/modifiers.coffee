goog.provide "coffeesound.compiler.planner.opcodes.modifiers"

goog.require "coffeesound.external.astjs"
goog.require "coffeesound.compiler.planner.utils"
goog.require "coffeesound.opcodes.modifiers"

do ->
  ENV_BUFFER_SIZE = 2048 #256

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

      if tree instanceof modifiers.BasicEnvelope
        # (max) TODO - use a noop audiobuffer instead?
        # (max) XXX - audio won't flow without a valid source
        osc = context.createOscillator()
        osc.frequency.setValueAtTime 0, context.currentTime
        osc.start(0)

        # mute the osc source
        gain = context.createGain()
        gain.gain.value = 0
        osc.connect(gain)

        # create the script processor and connect it to source
        args = [context.sampleRate].concat(tree.args)
        proc = BasicEnvelopeProcessor.apply({}, args)
        node = context.createScriptProcessor(ENV_BUFFER_SIZE, 2, 1)
        node.onaudioprocess = proc
        gain.connect(node)

        return [node]

  # Envelope states and transitions
  INACTIVE = 1  # -> [ATTACK]
  ATTACK = 2    # -> [DECAY,RELEASE]
  DECAY = 3     # -> [SUSTAIN,RELEASE]
  SUSTAIN = 4   # -> [RELEASE]
  RELEASE = 5   # -> [INACTIVE,ATTACK]

  # a function that binds the trigger and env params to the proc callback
  BasicEnvelopeProcessor = (SAMPLE_RATE,t,a,d,s,r,min,max) ->
    state = INACTIVE
    aLimit = aIndex = 0
    dLimit = dIndex = 0
    rLimit = rIndex = 0

    mkLimit = (factor) -> Math.max(1, Math.round(factor * SAMPLE_RATE))

    # this covers the following state transitions
    #   1) [INACTIVE] -> [ATTACK]
    #   2) [ATTACK,DECAY,SUSTAIN] -> [RELEASE]
    #   3) [RELEASE] -> [ATTACK]
    prepare = ->
      # kick off the attack phase
      if state == INACTIVE
        if t.value == on
          console.log("INACTIVE -> ATTACK")
          state = ATTACK
          aLimit = mkLimit(a.value)
          aIndex = 0

      # we're moving out of [ATTACK,DECAY,SUSTAIN] to [RELEASE]
      else if state != RELEASE and t.value == off
        console.log("[*] -> RELEASE")
        state = RELEASE
        rLimit = mkLimit(r.value)
        rIndex = 0

      # we're moving out of [RELEASE] to [ATTACK]
      else if state == RELEASE and t.value == on
        console.log("RELEASE -> ATTACK")
        state = ATTACK
        aLimit = mkLimit(a.value)
        aIndex = 0

    # this covers the follwoing state transitions
    #   1) [ATTACK] -> [DECAY]
    #   2) [DECAY] -> [SUSTAIN]
    #   3) [RELEASE] -> [INACTIVE]
    execute = (e) ->
      output = e.outputBuffer.getChannelData(0)
      minV = min.value
      maxV = max.value
      susV = minV + ((maxV - minV) * s.value)

      d1 = maxV - minV # delta used for ATTACK  -> DECAY
      d2 = susV - maxV # delta used for DECAY   -> SUSTAIN
      d3 = minV - susV # delta used for SUSTAIN -> RELEASE

      # short-ciruit if we come in inactive or sustained
      if state == INACTIVE
        output[i] = minV for i in [0...ENV_BUFFER_SIZE] by 1
        return
      else if state == SUSTAIN
        output[i] = susV for i in [0...ENV_BUFFER_SIZE] by 1
        return

      # simulate a do-while loop
      i = 0; loop
        if state == ATTACK
          incr = aLimit - aIndex
          if incr >= ENV_BUFFER_SIZE
            output[i++] = minV + (d1 * (aIndex++ / aLimit)) for _ in [0...ENV_BUFFER_SIZE] by 1
            return
          else
            console.log("ATTACK -> DECAY")
            output[i++] = minV + (d1 * (aIndex++ / aLimit)) for _ in [0...incr] by 1
            state = DECAY
            dLimit = mkLimit(d.value)
            dIndex = 0
        else if state == DECAY
          incr = dLimit - dIndex
          if incr >= ENV_BUFFER_SIZE
            output[i++] = maxV + (d2 * (dIndex++ / dLimit)) for _ in [0...ENV_BUFFER_SIZE] by 1
            return
          else
            console.log("DECAY -> SUSTAIN")
            output[i++] = maxV + (d2 * (dIndex++ / dLimit)) for _ in [0...incr] by 1
            state = SUSTAIN
        else if state == RELEASE
          incr = rLimit - rIndex
          if incr >= ENV_BUFFER_SIZE
            output[i++] = susV + (d3 * (rIndex++ / rLimit)) for _ in [0...ENV_BUFFER_SIZE] by 1
            return
          else
            console.log("RELEASE -> INACTIVE")
            output[i++] = susV + (d3 * (rIndex++ / rLimit)) for _ in [0...incr] by 1
            state = INACTIVE
        else if state == SUSTAIN
          output[i++] = susV for _ in [0...(ENV_BUFFER_SIZE - i)] by 1
          return
        else if state == INACTIVE
          output[i++] = minV for _ in [0...(ENV_BUFFER_SIZE - i)] by 1
          return
        else
          throw "invalid state: " + state

        return if i >= ENV_BUFFER_SIZE

    ((e) => prepare();execute(e))
