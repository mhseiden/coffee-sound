$(document).ready(function() {
  var AUDIO_FILE = "/audio/audio1.mp3",
      FFT_SIZE = 1024,
      INIT_SMOOTHING = 0.6,
      INIT_MIN_DBS = -100,
      INIT_MAX_DBS = -30,
      INIT_VOLUME = 0.25;

  var model = {
    smoothing: ko.observable(INIT_SMOOTHING),
    minDecibels: ko.observable(INIT_MIN_DBS),
    maxDecibels: ko.observable(INIT_MAX_DBS),
    volume: ko.observable(INIT_VOLUME),
  };

  ko.applyBindings(model,document.body);

  coffeesound.initialize().then(function() {
    var src = new coffeesound.opcodes.io.URLStreamInput(AUDIO_FILE, true);

    var fData = new coffeesound.expressions.data.DelegatedByteArray(FFT_SIZE);
    var smoothing = new coffeesound.expressions.Variable(INIT_SMOOTHING);
    var minDecibels = new coffeesound.expressions.Variable(INIT_MIN_DBS);
    var maxDecibels = new coffeesound.expressions.Variable(INIT_MAX_DBS);
    var fft = new coffeesound.opcodes.io.AnalyzerNode(src, fData, null,
      2 * FFT_SIZE, smoothing, minDecibels, maxDecibels);

    var volume = new coffeesound.expressions.Variable(INIT_VOLUME);
    var gain = new coffeesound.opcodes.modifiers.GainNode(fft, volume);
    var output = new coffeesound.opcodes.io.ContextOutput(gain);

    var analyzer = new coffeesound.compiler.analyzer.Analyzer();
    var planner = new coffeesound.compiler.planner.Planner();
    planner.plan(analyzer.execute(output));

    // connect the ko observables to the cs variables
    model.smoothing.subscribe(function(v) { smoothing.value = parseFloat(v); });
    model.volume.subscribe(function(v) { volume.value = parseFloat(v); });

    // min dbs cannot be larger than max dbs, so we put a guard here
    ko.pureComputed(function() {
      return {
        min: parseFloat(model.minDecibels()),
        max: parseFloat(model.maxDecibels()),
      };
    }).subscribe(function(v) {
        minDecibels.value = Math.min(v.min, v.max - 1);
        maxDecibels.value = Math.max(v.min, v.max);
    });

    (function render() {
      requestAnimationFrame(render);

      // a user-defined function that takes the
      // analyzer's u8 data buffer as an input
      // and updates a fft / music visualizer
      updateViz(fData.value);
    })();
  });
});
