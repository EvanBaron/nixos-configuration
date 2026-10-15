{ pkgs }:
let
  bands = 16;

  # Raw ASCII frames on stdout: one line per frame, "v;v;…;" with each v in 0..1000.
  cavaConfig = pkgs.writeText "cava-desk.conf" ''
    [general]
    bars = ${toString bands}
    framerate = 60
    sleep_timer = 2

    [input]
    method = pipewire
    source = auto

    [output]
    method = raw
    channels = mono
    mono_option = average
    raw_target = /dev/stdout
    data_format = ascii
    ascii_max_range = 1000
    bar_delimiter = 59
    frame_delimiter = 10

    [smoothing]
    noise_reduction = 60
  '';
in
''
  pragma Singleton
  import Quickshell
  import Quickshell.Io
  import QtQuick
  import "."

  // Audio features for the Desk, from cava over PipeWire. cava runs only while `wanted`
  // (some monitor shows an empty workspace). All values are 0..1 and 0 in silence.
  Singleton {
      id: root

      property bool wanted: false

      property real bass: 0
      property real mid: 0
      property real treble: 0
      property real beat: 0          // 1 on a detected kick, decays over ~300ms
      property real level: 0         // bass envelope: quick rise, ~0.5s release; holds while bass holds
      property bool silent: true     // nothing above the noise floor for 2s
      // Beat detection works on onsets (how sharply bass rises from one frame to the next),
      // not on the bass level: a sustained bass line pulls a level average up to itself
      // and hides the kicks on top of it. A rise counts when it stands out from the
      // recent spread of rises (mean + 1.5 sd, ~0.5s window).
      property real _prevBass: 0
      property real _fluxMean: 0
      property real _fluxVar: 0
      property real _lastBeat: 0
      property real _lastSound: 0

      function _follow(cur, target) {
          // Fast attack, slower release, so motion follows hits without flicker.
          return cur + (target - cur) * (target > cur ? 0.5 : 0.12)
      }

      Process {
          id: cava
          command: ["${pkgs.cava}/bin/cava", "-p", "${cavaConfig}"]
          running: root.wanted
          stdout: SplitParser {
              onRead: data => {
                  var v = data.split(";")
                  function band(a, b) {
                      var s = 0
                      for (var i = a; i <= b; i++) { var x = parseInt(v[i]); s += isNaN(x) ? 0 : x }
                      return s / ((b - a + 1) * 1000)
                  }
                  var b = band(0, 2), m = band(3, 8), t = band(9, ${toString (bands - 1)})
                  root.bass = root._follow(root.bass, b)
                  root.mid = root._follow(root.mid, m)
                  root.treble = root._follow(root.treble, t)
                  root.level += (b - root.level) * (b > root.level ? 0.35 : 0.035)

                  var now = Date.now()
                  var flux = Math.max(0, b - root._prevBass)
                  root._prevBass = b
                  var threshold = Math.max(0.04, root._fluxMean + 1.5 * Math.sqrt(root._fluxVar))
                  if (flux > threshold && now - root._lastBeat > 150) {
                      root.beat = 1
                      root._lastBeat = now
                  } else {
                      root.beat *= 0.9
                  }
                  root._fluxMean = root._fluxMean * 0.97 + flux * 0.03
                  root._fluxVar = root._fluxVar * 0.97 + (flux - root._fluxMean) * (flux - root._fluxMean) * 0.03
                  if (b + m + t > 0.02) { root._lastSound = now; root.silent = false }
              }
          }
          onRunningChanged: if (!running) root.reset()
      }

      function reset() {
          bass = 0; mid = 0; treble = 0; beat = 0; level = 0; silent = true
          _prevBass = 0; _fluxMean = 0; _fluxVar = 0
      }

      // cava stops printing while it sleeps, so silence is detected here.
      Timer {
          interval: 250; repeat: true; running: cava.running && !root.silent
          onTriggered: if (Date.now() - root._lastSound > 2000) root.reset()
      }
  }
''
