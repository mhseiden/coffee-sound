goog.provide "coffeesound.clock"

goog.require "coffeesound"

coffeesound.initialize().then ->
    context = coffeesound._context

    CLOCK_LENGTH  = 1024
    ONCE_INTERVAL = -1

    context = coffeesound._context

    bpm = 120
    resolution = 16
    secondsPerTick = 60.0 / (bpm * resolution)
    timeOffset = 0.0

    removed = {}
    clock = []
    do -> clock[idx] = [] for idx in [0...CLOCK_LENGTH]

    nextCallbackID = 1
    clockPointer = 0
    lookahead = 1
    lastSeenTick = 0

    checkClock = ->
      basePointer = clockPointer

      currentTime = context.currentTime
      nextTick = computeNextTick(currentTime)
      if lastSeenTick != nextTick
        for offset in [0...lookahead] by 1
          pointer = (basePointer + offset) % CLOCK_LENGTH
          queue = clock[pointer]
          while (callback = queue.pop())?
            if removed[callback._id]?
              delete removed[callback._id]
            else
              try
                execute(callback,currentTime,offset)
              catch e
                console.log(e)
              addCallback(offset,callback)

      requestAnimationFrame(checkClock)

    coffeesound.clock.bpm = (bpm0) ->
      bpm = bpm0
      secondsPerTick = computeSecondsPerTick()

    coffeesound.clock.resolution = (resolution0) ->
      resolution = resolution0
      secondsPerTick = computeSecondsPerTick()

    computeSecondsPerTick = ->
      60.0 / (bpm * resolution)

    coffeesound.clock.cancel = (id) ->
      removed[id] = true

    coffeesound.clock.quantize = (callback, timestamp = context.currentTime) ->
      schedule(ONCE_INTERVAL, 0, callback, timestamp)

    coffeesound.clock.once = (offset, callback, timestamp = context.currentTime) ->
      schedule(ONCE_INTERVAL, offset, callback, timestamp)
      coffeesound.clock.loop(ONCE_INTERVAL,offset,callback,timestamp)

    coffeesound.clock.loop = (interval, offset, callback, timestamp = context.currentTime) ->
      schedule(interval, offset, callback, timestamp)

    schedule = (interval, offset, callback, timestamp) ->
      if 0 == offset
        execute(callback,timestamp,0)
        offset = interval # ensure we don't double schedule the event

      if ONCE_INTERVAL != interval
        callback._id = nextCallbackID++
        callback._interval = interval
        addCallback(offset,callback)

    execute = (callback, currentTime, ticks) ->
      nextTick = computeNextTick(currentTime) + (ticks * secondsPerTick)
      callback(nextTick)

    addCallback = (offset,callback) ->
      pos = clockPointer + callback._interval + offset
      idx = pos % CLOCK_LENGTH
      clock[idx].push(callback)

    computeNextTick = (currentTime) ->
      # ticks cannot be negative, so we can never have a next tick less than zero
      return 1 if 0 >= currentTime

      now = currentTime - timeOffset
      relativeTick = Math.ceil(now / secondsPerTick) * secondsPerTick
      return relativeTick + timeOffset

    requestAnimationFrame(checkClock)
