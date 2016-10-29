goog.provide "coffeesound.expressions"

goog.require "coffeesound.external.knockout"
goog.require "coffeesound.external.astjs"
goog.require "coffeesound"

###
  TODO URGENT!!!
  
  We must flow the absolute context timestamp along with all observable
  updates so we can correctly schedule updates on the timeline. This was
  a major flaw in all the prior versions, and resulted in a lot of nasty
  boilerplate in the client code to ensure event timing was correct.
###

do ->
  KO      = coffeesound.external.knockout
  ASTJS   = coffeesound.external.astjs
  E_RATE  = coffeesound.RATE.E_RATE

  coffeesound.expressions.bindSubscribe =
  bindSubscribe = (object,observable) ->
    object.subscribe = (cb,target,ev) -> observable.subscribe(cb,target,ev)

  coffeesound.expressions.bindValue =
  bindValue = (object,initial) ->
    value = KO.observable(initial)
    value.toString = -> "Reactive[#{value()}]"

    Object.defineProperty object, "value",
      get: ( ) -> value()
      set: (v) -> value(v)

    bindSubscribe object, value
    return value

  coffeesound.expressions.bindComputed =
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

  # a trigger, analogous to a Max/MSP bang!
  coffeesound.expressions.Bang =
  class Bang extends LeafExpression
    constructor: ->
      @handle = handle = ko.observable(null)
      bindSubscribe @, handle
      super(Bang,[])

    bang: -> @handle.valueHasMutated()

