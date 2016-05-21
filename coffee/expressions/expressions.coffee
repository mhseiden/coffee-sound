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


  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # Array Data Containers 
  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  class LazyArray
    fill: -> # noop by default
    constructor: (@buffer) ->
      Object.defineProperty @, "value",
        set: (v) => @buffer = v
        get: ( ) =>
          @fill(@buffer)
          return @buffer

  class DelegatedArray extends LeafExpression
    # (max) TODO - this could be done...the semantics emitting an event just kinda weird
    # (i.e.) a read performs an update which results in an event getting fired...?
    subscribe: -> throw new Error("cannot subscribe to changes from a DelegatedArray")

    constructor: (ctor,size,data) ->
      Object.defineProperty @, "value",
        set: (v) => @container().value = v
        get: ( ) => @container().value
      super(ctor,[size,new LazyArray(data)])

    size:      -> @args[0]
    container: -> @args[1]

  coffeesound.expressions.DelegatedByteArray =
  class DelegatedByteArray extends DelegatedArray
    constructor: (size = 0) ->
      super(DelegatedByteArray, size, new Uint8Array(size))

  coffeesound.expressions.DelegatedFloatArray =
  class DelegatedFloatArray extends DelegatedArray
    constructor: (size = 0) ->
      super(DelegatedFloatArray, size, new Float32Array(size))

  # (max) TODO - the compiler should reactively decode the given buffer
  coffeesound.expressions.EncodedAudioBuffer =
  class EncodedAudioBuffer extends LeafExpression
    constructor: (buffer) ->
      super(EncodedAudioBuffer,[buffer])

  coffeesound.expressions.DecodedAudioBuffer =
  class DecodedAudioBuffer extends LeafExpression
    constructor: (buffer) ->
      super(DecodedAudioBuffer,[buffer])
