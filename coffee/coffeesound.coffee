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

coffeesound.options =
  microphone  : off
  webmidi     : off

coffeesound.initialize = ->
  unless coffeesound._startupPromise?
    coffeesound._startupPromise = Promise.resolve do ->
      if "undefined" != typeof(AudioContext)
        coffeesound._context = new AudioContext
      else
        coffeesound._context = new webkitAudioContext

      # TODO - if WebMidi is enabled, initialize it

      # if the mic is enabled, initialize it
      if coffeesound.options.microphone is on
        return new Promise (res,rej) ->
          if "undefined" != typeof(navigator.webkitGetUserMedia)
            navigator.getUserMedia = navigator.webkitGetUserMedia

          if navigator.getUserMedia?
            cback = ((m) -> coffeesound._microphone = m; res())
            eback = ((e) -> console.log("unable to initialize microphone",e); res())
            navigator.getUserMedia((audio: true),cback,eback)
          else
            console.log("microphone access is not supported")
            res()

  return coffeesound._startupPromise
