$(document).ready(function() {
  INITIAL_FREQUENCY = 220;
  INITIAL_DETUNE    = 0;
  INITIAL_WAVEFORM  = "sine";
  INITIAL_VOLUME    = 0.25;

  var model = window._model = {
    frequency : ko.observable(INITIAL_FREQUENCY),
    detune    : ko.observable(INITIAL_DETUNE),
    waveform  : ko.observable(INITIAL_WAVEFORM),
    volume    : ko.observable(INITIAL_VOLUME)
  }

  ko.applyBindings(model,document.body);

  coffeesound.initialize().then(function() {
    // define the variables we'll feed into the audio nodes
    var frequency = new coffeesound.expressions.Variable(INITIAL_FREQUENCY);
    var detune = new coffeesound.expressions.Variable(INITIAL_DETUNE);
    var waveform = new coffeesound.expressions.Variable(INITIAL_WAVEFORM);
    var volume = new coffeesound.expressions.Variable(INITIAL_VOLUME);

    // connect the ko observables to the cs variables
    model.frequency.subscribe(function(v) { frequency.value = parseInt(v); });
    model.detune.subscribe(function(v) { detune.value = parseInt(v); });
    model.waveform.subscribe(function(v) { waveform.value = v; });
    model.volume.subscribe(function(v) { volume.value = parseFloat(v); });

    // define the audio node graph
    var oscillator = new coffeesound.opcodes.generators.OscillatorNode(frequency,detune,waveform);
    var gain = new coffeesound.opcodes.modifiers.GainNode(oscillator,volume);
    var output = new coffeesound.opcodes.io.ContextOutput(gain);

    // analyze and plan our audio graph
    var analyzer = new coffeesound.compiler.analyzer.Analyzer();
    var planner = new coffeesound.compiler.planner.Planner();
    planner.plan(analyzer.execute(output));
  });
});
