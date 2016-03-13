goog.provide "coffeesound.compiler.analyzer.types"

goog.require "coffeesound.external.astjs"
ASTJS = coffeesound.external.astjs

goog.require "coffeesound.expressions"
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
    tree.transform (node) ->
      newArgs = _.map node.args, (arg) -> if arg instanceof ExpressionTree then arg else new Literal(arg)
      return node.copy(newArgs,node.children)

