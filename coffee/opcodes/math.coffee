goog.provide "coffeesound.opcodes.math"

goog.require "coffeesound"
goog.require "coffeesound.opcodes"

do ->
  A_RATE = coffeesound.RATE.A_RATE

  coffeesound.opcodes.math.Add =
  class Add extends coffeesound.opcodes.BinaryNode
    constructor: (left,right) ->
      super(A_RATE,Add,left,right,[])

  coffeesound.opcodes.math.Sub =
  class Sub extends coffeesound.opcodes.BinaryNode
    constructor: (left,right) ->
      super(A_RATE,Sub,left,right,[])

  coffeesound.opcodes.math.Mul =
  class Mul extends coffeesound.opcodes.BinaryNode
    constructor: (left,right) ->
      super(A_RATE,Mul,left,right,[])

  coffeesound.opcodes.math.Div =
  class Div extends coffeesound.opcodes.BinaryNode
    constructor: (left,right) ->
      super(A_RATE,Div,left,right,[])
