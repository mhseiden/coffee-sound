goog.provide "coffeesound.opcodes"

goog.require "coffeesound.external.astjs"

do ->
  ASTJS = coffeesound.external.astjs

  coffeesound.opcodes.TreeNode =
  class TreeNode extends ASTJS.TreeNode
    constructor: (@rate,ctor,children,args) ->
      super(ctor,args,children)

  coffeesound.opcodes.LeafNode =
  class LeafNode extends TreeNode
    constructor: (rate,ctor,args) ->
      super(rate,ctor,[],args)

  coffeesound.opcodes.UnaryNode =
  class UnaryNode extends TreeNode
    constructor: (rate,ctor,child,args) ->
      super(rate,ctor,[child],args)

  coffeesound.opcodes.BinaryNode =
  class BinaryNode extends TreeNode
    constructor: (rate,ctor,l,r,args) ->
      super(rate,ctor,[l,r],args)

