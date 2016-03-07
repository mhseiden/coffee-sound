goog.provide "coffeesound.opcode.expressions"

goog.require "coffeesound.opcode"

E_RATE = coffeesound.opcode.RATE.E_RATE

coffeesound.opcode.expressions.ExpressionTree =
class Expression extends coffee.opcode.TreeNode
  constructor: (ctor,children,args) ->
    super(E_RATE,ctor,children,args)

coffeesound.opcode.expressions.LeafExpression =
class LeafExpression extends ExpressionTree
  constructor: (ctor,args) ->
    super(ctor,[],args)

coffeesound.opcode.expressions.UnaryExpression =
class UnaryExpression extends ExpressionTree
  constructor: (ctor,child,args) ->
    super(ctor,[child],args)

coffeesound.opcode.expressions.BinaryExpression =
class BinaryExpression extends ExpressionTree
  constructor: (ctor,l,r,args) ->
    super(ctor,[l,r],args)

# an immutable value
coffeesound.opcode.expressions.Literal =
class Literal extends LeafExpression
  constructor: (value) ->
    super(Literal,[value])

# a mutable, reactive value
coffeesound.opcode.expressions.Value =
class Value extends LeafExpression
  constructor: (initial) ->
    super(Value,[initial])

# arithmetic - Add
coffeesound.opcode.expressions.Add =
class Add extends BinaryNode
  constructor: (l,r) ->
    super(Add,l,r,[])

# arithmetic - Sub
coffeesound.opcode.expressions.Sub =
class Sub extends BinaryNode
  constructor: (l,r) ->
    super(Sub,l,r,[])

# arithmetic - Mul
coffeesound.opcode.expressions.Mul =
class Mul extends BinaryNode
  constructor: (l,r) ->
    super(Mul,l,r,[])

# arithmetic - Div
coffeesound.opcode.expressions.Div =
class Div extends BinaryNode
  constructor: (l,r) ->
    super(Div,l,r,[])

