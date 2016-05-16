goog.provide "coffeesound.compiler.planner.opcodes.math"

goog.require "coffeesound.external.astjs"
goog.require "coffeesound.compiler.planner.utils"
goog.require "coffeesound.opcodes.math"

do ->
  SCRIPT_BUFFER_SIZE = 1024
  ASTJS = coffeesound.external.astjs
  { bindParam, bindValue, bindCallback } = coffeesound.compiler.planner.utils

  Add = (a,b) -> a+b
  Sub = (a,b) -> a-b
  Mul = (a,b) -> a*b
  Div = (a,b) -> if b == 0 then 0 else a/b

  # a function bound with a buffer size and binary arithmetic operation
  StereoBinaryProcessor = (bufferSize,op) -> (e) ->
    iBuffers = e.inputBuffer
    oBuffers = e.outputBuffer

    # pull out the left buffers
    i1Left = iBuffers.getChannelData(0)
    i2Left = iBuffers.getChannelData(1)
    oLeft = oBuffers.getChannelData(0)

    # pull out the right buffers
    i1Right = iBuffers.getChannelData(2)
    i2Right = iBuffers.getChannelData(3)
    oRight = oBuffers.getChannelData(1)

    # do a single pass over both buffers and scale down by 50%
    for i in [0...bufferSize] by 1
      oLeft[i]  = 0.5 * op(i1Left[i],i2Left[i])
      oRight[i] = 0.5 * op(i1Right[i],i2Right[i])
    return

  mkBinaryScriptProcessor = (tree,planner) ->
    context = coffeesound._context

    l = planner.planLater(tree.children[0])
    lSplit = context.createChannelSplitter(2)
    l.connect(lSplit)

    r = planner.planLater(tree.children[1])
    rSplit = context.createChannelSplitter(2)
    r.connect(rSplit)

    merger = context.createChannelMerger(4)

    # merge channel 0 from both nodes
    lSplit.connect(merger,0,0)
    rSplit.connect(merger,0,1)

    # merge channel 1 from both nodes
    lSplit.connect(merger,(if 2 == l.channelCount then 1 else 0),2)
    rSplit.connect(merger,(if 2 == r.channelCount then 1 else 0),3)

    processor = context.createScriptProcessor(SCRIPT_BUFFER_SIZE,4,2)
    merger.connect(processor)
    return processor

  coffeesound.compiler.planner.opcodes.math.Strategy =
  class Strategy extends ASTJS.PlannerStrategy
    execute: (tree) ->
      math = coffeesound.opcodes.math
      if tree instanceof math.Add
        node = mkBinaryScriptProcessor(tree,@planner)
        node.onaudioprocess = StereoBinaryProcessor(node.bufferSize,Add)
        return [node]

      if tree instanceof math.Mul
        node = mkBinaryScriptProcessor(tree,@planner)
        node.onaudioprocess = StereoBinaryProcessor(node.bufferSize,Mul)
        return [node]

      if tree instanceof math.Sub
        node = mkBinaryScriptProcessor(tree,@planner)
        node.onaudioprocess = StereoBinaryProcessor(node.bufferSize,Sub)
        return [node]

      if tree instanceof math.Div
        node = mkBinaryScriptProcessor(tree,@planner)
        node.onaudioprocess = StereoBinaryProcessor(node.bufferSize,Div)
        return [node]
