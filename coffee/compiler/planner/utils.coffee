goog.provide "coffeesound.compiler.planner.utils"

do ->
  extractExpression = (node,name) ->
    if _.isFunction(node[name])
      return node[name]()
    else
      return node[name]

  coffeesound.compiler.planner.utils.bindValue =
  bindValue = (source,sourceName,target,targetName = sourceName) ->
    src = extractExpression(source,sourceName)
    src.subscribe (v) -> target[targetName] = v
    target[targetName] = src.value
    return

  coffeesound.compiler.planner.utils.bindCallback =
  bindCallback = (source,sourceName,callback,call = yes) ->
    src = extractExpression(source,sourceName)
    src.subscribe(callback)
    callback(src.value) if call
