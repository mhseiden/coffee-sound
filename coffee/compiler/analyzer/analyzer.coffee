goog.provide "coffeesound.compiler.analyzer"

goog.require "coffeesound.external.astjs"
goog.require "coffeesound.compiler.analyzer.types"

do ->
  ASTJS = coffeesound.external.astjs

  coffeesound.compiler.analyzer.Analyzer =
  class Analyzer extends ASTJS.RuleExecutor
    constructor: ->
      super([
        new coffeesound.compiler.analyzer.types.TypingBatch()
      ])
