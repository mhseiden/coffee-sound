goog.provide "coffeesound.expressions"

goog.require "coffeesound.external.astjs"
goog.require "coffeesound"

do ->
  KO      = coffeesound.external.knockout
  ASTJS   = coffeesound.external.astjs
  E_RATE  = coffeesound.RATE.E_RATE

  bindSubscribe = (object,observable) ->
    object.subscribe = (cb,target,ev) -> observable.subscribe(cb,target,ev)

  bindValue = (object,initial) ->
    value = KO.observable(initial)
    value.toString = -> "Reactive[#{value()}]"

    Object.defineProperty object, "value",
      get: ( ) -> value()
      set: (v) -> value(v)

    bindSubscribe object, value
    return value

  bindComputed = (object,fn) ->
    computed = KO.pureComputed(fn)
    computed.toString = -> "Reactive[#{computed()}]"

    Object.defineProperty object, "value",
      get: ( ) -> computed()
      set: ( ) -> # noop

    bindSubscribe object, computed
    return computed

  coffeesound.expressions.ExpressionTree =
  class ExpressionTree extends ASTJS.TreeNode
    rate: E_RATE

    constructor: (ctor,children,args) ->
      super(ctor,args,children)

  coffeesound.expressions.LeafExpression =
  class LeafExpression extends ExpressionTree
    constructor: (ctor,args) ->
      super(ctor,[],args)

  coffeesound.expressions.UnaryExpression =
  class UnaryExpression extends ExpressionTree
    constructor: (ctor,child,args) ->
      super(ctor,[child],args)

  coffeesound.expressions.BinaryExpression =
  class BinaryExpression extends ExpressionTree
    constructor: (ctor,l,r,args) ->
      super(ctor,[l,r],args)

# an immutable value
  coffeesound.expressions.Literal =
  class Literal extends LeafExpression
    constructor: (literal) ->
      bound = bindComputed @, -> literal
      super(Literal,[bound])

# a mutable, reactive value
  coffeesound.expressions.Variable =
  class Variable extends LeafExpression
    constructor: (initial) ->
      bound = bindValue @, initial
      super(Variable,[bound])

# arithmetic - Add
  coffeesound.expressions.Add =
  class Add extends BinaryExpression
    constructor: (l,r) ->
      bindComputed @, -> l.value + r.value
      super(Add,l,r,[])

# arithmetic - Sub
  coffeesound.expressions.Sub =
  class Sub extends BinaryExpression
    constructor: (l,r) ->
      bindComputed @, -> l.value - r.value
      super(Sub,l,r,[])

# arithmetic - Mul
  coffeesound.expressions.Mul =
  class Mul extends BinaryExpression
    constructor: (l,r) ->
      bindComputed @, -> l.value * r.value
      super(Mul,l,r,[])

# arithmetic - Div
  coffeesound.expressions.Div =
  class Div extends BinaryExpression
    constructor: (l,r) ->
      bindComputed @, -> l.value / r.value
      super(Div,l,r,[])
