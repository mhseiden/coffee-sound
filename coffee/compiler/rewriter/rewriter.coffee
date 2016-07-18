goog.provide "coffeesound.compiler.rewriter"

goog.require "coffeesound.external.astjs"

do ->
  ASTJS = coffeesound.external.astjs

  coffeesound.compiler.rewriter.Rewriter =
  class Rewriter extends ASTJS.RuleExecutor
    constructor: -> super([])
