$(document).ready(function() {
  AUDIO_FILE = "/audio/audio3.mp3";
  WAVEFORM_WIDTH = 720;
  INITIAL_MULTI = false;
  INITIAL_START = 0.0;
  INITIAL_END = 1.0;
  INITIAL_VOLUME = 0.25;

  var model = {
    start: ko.observable(INITIAL_START),
    end: ko.observable(INITIAL_END),
    volume: ko.observable(INITIAL_VOLUME),
    multi: ko.observable(INITIAL_MULTI),
    bang: new coffeesound.expressions.Bang(), // a bang to trigger the oneshot
  };

  ko.applyBindings(model,document.body);

  coffeesound.initialize().then(function() {
    function load(encAudio) {
      // scalar variables
      var start = new coffeesound.expressions.Variable(INITIAL_START);
      var end = new coffeesound.expressions.Variable(INITIAL_END);
      var cancel = new coffeesound.expressions.Variable(!INITIAL_MULTI);
      var volume = new coffeesound.expressions.Variable(INITIAL_VOLUME);

      // a buffer and a reactive slice
      var buffer = new coffeesound.expressions.data.EncodedAudioBuffer(encAudio);
      var sliced = new coffeesound.expressions.data.SliceAudioBuffer(buffer,start,end);

      // setup the audio graph
      var oneshot = new coffeesound.opcodes.buffers.OneShot(sliced, model.bang, cancel);
      var gain = new coffeesound.opcodes.modifiers.GainNode(oneshot, volume);
      var output = new coffeesound.opcodes.io.ContextOutput(gain);

      // analyze and plan our audio graph
      var analyzer = new coffeesound.compiler.analyzer.Analyzer();
      var planner = new coffeesound.compiler.planner.Planner();
      planner.plan(analyzer.execute(output));

      // bind the ko observables to the cs variables
      model.multi.subscribe(function(v) { cancel.value = !v; });
      model.start.subscribe(function(v) { start.value = v; });
      model.end.subscribe(function(v) { end.value = v; });
      model.volume.subscribe(function(v) { volume.value = v; });

      // render the waveform once the buffer has loaded
      buffer.subscribe(function() { renderWaveform(buffer.value, 2048); });
    };

    var xhr = new XMLHttpRequest();
    xhr.open("GET", AUDIO_FILE);
    xhr.responseType = "arraybuffer";
    xhr.onreadystatechange = function(r) { if(4 === xhr.readyState) load(xhr.response); };
    xhr.send();
  });

  // jQuery sampler interactions
  var $leftGrip = $(".handle-bar .grip-left"),
      $leftBar = $leftGrip.parent(),
      $rightGrip = $(".handle-bar .grip-right"),
      $rightBar = $rightGrip.parent();

  $leftBar.css("left", (100 * INITIAL_START) + "%");
  $rightBar.css("left", (100 * INITIAL_END) + "%");

  $(".handle-bar .grip").on("mousedown", function(e) {
    var isLeft = $(e.target).hasClass("grip-left"),
        $bar = isLeft ? $leftBar : $rightBar,
        $grip = isLeft ? $leftGrip : $rightGrip,
        minPos = isLeft ? 0 : parseInt($leftBar.css("left")),
        maxPos = isLeft ? parseInt($rightBar.css("left")) : WAVEFORM_WIDTH,
        samplePos = isLeft ? model.start : model.end,
        barOffset = parseInt($bar.css("left")),
        pageOffset = e.pageX;

    // show a pointer as we move the bar
    $(document.body).css("cursor", "pointer");

    $(document).on("mousemove.handle-grip", function(e) {
      var mouseDelta = e.pageX - pageOffset,
          rawPosition = mouseDelta + barOffset,
          safePosition = Math.min(Math.max(rawPosition, minPos), maxPos),
          pctPosition = 100 * (safePosition / WAVEFORM_WIDTH);
      $bar.css("left", pctPosition + "%");
    });

    $(document).on("mouseup.handle-grip", function(e) {
      samplePos(parseInt($bar.css("left")) / WAVEFORM_WIDTH);
      $(document.body).css("cursor", "auto");
      $(document).off("mousemove.handle-grip mouseup.handle-grip")
    });
  });

});
