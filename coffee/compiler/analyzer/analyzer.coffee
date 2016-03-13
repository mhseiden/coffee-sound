goog.provide "coffeesound.compiler.analyzer"

goog.require "coffeesound.external.astjs"
ASTJS = coffeesound.external.astjs

# analyzer rules and batches
goog.require "coffeesound.compiler.analyzer.types"

coffeesound.compiler.analyzer.Analyzer =
class Analyzer extends ASTJS.RuleExecutor
  constructor: ->
    super([
      new coffeesound.compiler.analyzer.types.TypingBatch()
    ])
