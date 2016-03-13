goog.provide "coffeesound"

goog.require "coffeesound.external.astjs"
coffeesound.external.astjs = window.astjs

goog.require "coffeesound.external.knockout"
coffeesound.external.knockout = window.ko

coffeesound.RATE =
  ANY_RATE  : "ANY_RATE"
  A_RATE    : "A_RATE"
  K_RATE    : "K_RATE"
  E_RATE    : "E_RATE"

coffeesound._context = do -> new (AudioContext || webkitAudioContext)
