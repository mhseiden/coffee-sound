goog.provide "coffeesound.compiler"

coffeesound.compiler.compile = (plan) ->
  analyzer = new coffeesound.compiler.analyzer.Analyzer()
  planner = new coffeesound.compiler.planner.Planner()
  planner.plan(analyzer.execute(plan))
