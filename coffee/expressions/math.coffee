goog.provide "coffeesound.expressions.math"

goog.require "coffeesound.expressions"

do ->
  { UnaryExpression, BinaryExpression, bindComputed } = coffeesound.expressions

  coffeesound.expressions.math.Add =
  class Add extends BinaryExpression
    constructor: (l,r) ->
      bindComputed @, -> l.value + r.value
      super(Add,l,r,[])

  coffeesound.expressions.math.Sub =
  class Sub extends BinaryExpression
    constructor: (l,r) ->
      bindComputed @, -> l.value - r.value
      super(Sub,l,r,[])

  coffeesound.expressions.math.Mul =
  class Mul extends BinaryExpression
    constructor: (l,r) ->
      bindComputed @, -> l.value * r.value
      super(Mul,l,r,[])

  coffeesound.expressions.math.Div =
  class Div extends BinaryExpression
    constructor: (l,r) ->
      bindComputed @, -> l.value / r.value
      super(Div,l,r,[])

  coffeesound.expressions.math.Neg =
  class Neg extends UnaryExpression
    constructor: (v) ->
      bindComputed @, -> -1 * v.value
      super(Neg,v,[])
