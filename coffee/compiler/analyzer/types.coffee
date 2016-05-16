goog.provide "coffeesound.compiler.analyzer.types"

goog.require "coffeesound.external.astjs"
goog.require "coffeesound.expressions"

do ->
  ASTJS = coffeesound.external.astjs

  { ExpressionTree, Literal } = coffeesound.expressions

  coffeesound.compiler.analyzer.types.TypingBatch =
  class TypingBatch extends ASTJS.RuleBatch
    constructor: ->
      super([
        new InjectLiterals()
      ],1)


  class InjectLiterals extends ASTJS.Rule
    constructor: -> super()

    execute: (tree) ->
      tree.transformUp (node) ->
        newArgs = _.map node.args, (arg) -> if arg instanceof ExpressionTree then arg else new Literal(arg)
        newNode = node.copy(newArgs,node.children)
        newNode.nodeid = node.nodeid # injecting literals doesn't change the node's meaning
        return newNode

