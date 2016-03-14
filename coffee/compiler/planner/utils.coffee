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
  bindParam = (source,sourceName,param) ->
    # (max) TODO - fix this so we can bind param -> param
    src = extractExpression(source,sourceName)
    if RATE.E_RATE is src.rate
      src.subscribe (v) -> setParam(param,v)
      setParam(param,src.value)
    else
      throw new Error("cannot bind source of type: #{source.rate}")
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
