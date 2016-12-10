goog.provide "coffeesound.compiler.planner.utils"

goog.require "coffeesound"

do ->
  RATE = coffeesound.RATE

  # (max) TODO - make this a fn arg instead...?
  context = coffeesound._context

  extractExpression = (node,name) ->
    if _.isFunction(node[name])
      return node[name]()
    else
      return node[name]

  setParam = (param,value,timestamp = context.currentTime) ->
    param.cancelScheduledValues(timestamp)
    param.setValueAtTime(value,timestamp)

  coffeesound.compiler.planner.utils.bindParam =
  bindParam = (source,sourceName,param,planner) ->
    src = extractExpression(source,sourceName)
    if RATE.A_RATE is src.rate
      if null != (node = planner.planLater(src))
        param.value = 0 # "[...] summing with the intrinsic parameter value" - see: https://webaudio.github.io/web-audio-api/#AudioParam
        node.connect(param)
      else
        throw new Error("unable to plan node: #{src}")
    else if RATE.E_RATE is src.rate
      src.subscribe (v) -> setParam(param,v)
      setParam(param,src.value)
    else
      throw new Error("cannot bind source of type: #{src.rate}")
    return

  coffeesound.compiler.planner.utils.bindValue =
  bindValue = (source,sourceName,target,targetName = sourceName) ->
    src = extractExpression(source,sourceName)
    src.subscribe (v) -> target[targetName] = v
    target[targetName] = src.value
    return

  coffeesound.compiler.planner.utils.bindCallback =
  bindCallback = (source,sourceName,callback) ->
    src = extractExpression(source,sourceName)
    src.subscribe(callback)
    callback(src.value)
    return
