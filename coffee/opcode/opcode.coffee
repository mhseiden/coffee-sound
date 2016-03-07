goog.provide "coffeesound.opcode"

goog.require "coffeesound.external.astjs"
goog.require "coffeesound.external.underscore"

ASTJS = coffeesound.external.astjs

coffeesound.opcode.RATE =
  ANY_RATE  : "ANY_RATE"
  A_RATE    : "A_RATE"
  K_RATE    : "K_RATE"
  E_RATE    : "E_RATE"

coffeesound.opcode.TreeNode =
class TreeNode extends ASTJS.TreeNode
  constructor: (@rate,ctor,children,args) ->
    super(ctor,children,args)

coffeesound.opcode.LeafNode =
class LeafNode extends TreeNode
  constructor: (rate,ctor,args) ->
    super(rate,ctor,[],args)

coffeesound.opcode.UnaryNode =
class UnaryNode extends TreeNode
  constructor: (rate,ctor,child,args) ->
    super(rate,ctor,[child],args)

coffeesound.opcode.BinaryNode =
class BinaryNode extends TreeNode
  constructor: (rate,ctor,l,r,args) ->
    super(rate,ctor,[l,r],args)

