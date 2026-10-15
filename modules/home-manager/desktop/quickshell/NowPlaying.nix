{ ... }:
''
  pragma Singleton
  import Quickshell
  import Quickshell.Services.Mpris
  import QtQuick

  // The current MPRIS player for the Desk, its position, and time-synced lyrics from
  // LRCLIB (https://lrclib.net; sends the artist, title, album and length of the track).
  // Polls and fetches only while `active`.
  Singleton {
      id: root

      property bool active: false

      // Same choice as the control center: a playing player, else one with a track.
      readonly property var player: {
          var v = Mpris.players.values
          for (var i = 0; i < v.length; i++) if (v[i].isPlaying) return v[i]
          for (var j = 0; j < v.length; j++) if (v[j].trackTitle) return v[j]
          return null
      }
      readonly property bool hasTrack: player !== null && (player.trackTitle || "") !== ""
      readonly property string title: hasTrack ? player.trackTitle : ""
      readonly property string artist: hasTrack ? (player.trackArtist || "") : ""
      readonly property string album: hasTrack ? (player.trackAlbum || "") : ""
      readonly property string artUrl: hasTrack ? (player.trackArtUrl || "") : ""
      readonly property real length: hasTrack ? player.length : 0
      readonly property bool playing: hasTrack && player.isPlaying
      property real position: 0

      // [{ t: seconds, text }] sorted by t; empty when the track has no synced lyrics.
      property var lyrics: []
      readonly property int lineIndex: {
          var p = position + 0.15, idx = -1
          for (var i = 0; i < lyrics.length; i++) { if (lyrics[i].t <= p) idx = i; else break }
          return idx
      }

      readonly property bool canPrevious: hasTrack && player.canGoPrevious
      readonly property bool canNext: hasTrack && player.canGoNext
      readonly property bool canSeek: hasTrack && player.canSeek && length > 0

      function togglePlaying() { if (player && player.canTogglePlaying) player.togglePlaying() }
      function previous() { if (canPrevious) player.previous() }
      function next() { if (canNext) player.next() }
      function seek(fraction) {
          if (!canSeek) return
          player.position = Math.max(0, Math.min(1, fraction)) * length
          position = player.position
      }

      Timer {
          interval: 250; repeat: true
          running: root.active && root.hasTrack
          triggeredOnStart: true
          onTriggered: { root.player.positionChanged(); root.position = root.player.position }
      }

      // ── Lyrics ──
      property var _cache: ({})
      property string _key: ""
      readonly property string trackKey: hasTrack ? artist + "\u001f" + title : ""
      onTrackKeyChanged: if (active) fetchLyrics()
      onActiveChanged: if (active && trackKey !== _key) fetchLyrics()

      function parseLrc(text) {
          var out = []
          var lines = (text || "").split("\n")
          for (var i = 0; i < lines.length; i++) {
              var l = lines[i], m, stamps = []
              var re = /\[(\d+):(\d+(?:\.\d+)?)\]/g
              var last = 0
              while ((m = re.exec(l)) !== null) { stamps.push(parseInt(m[1]) * 60 + parseFloat(m[2])); last = re.lastIndex }
              var words = l.slice(last).trim()
              for (var k = 0; k < stamps.length; k++) out.push({ t: stamps[k], text: words })
          }
          out.sort(function(a, b) { return a.t - b.t })
          return out
      }

      function _get(url, done) {
          var xhr = new XMLHttpRequest()
          xhr.onreadystatechange = function() {
              if (xhr.readyState !== XMLHttpRequest.DONE) return
              var body = null
              if (xhr.status === 200) { try { body = JSON.parse(xhr.responseText) } catch (_) {} }
              done(body)
          }
          xhr.open("GET", url)
          xhr.send()
      }

      function fetchLyrics() {
          var key = trackKey
          _key = key
          if (key === "") { lyrics = []; return }
          if (_cache[key] !== undefined) { lyrics = _cache[key]; return }
          lyrics = []
          var q = "track_name=" + encodeURIComponent(title) + "&artist_name=" + encodeURIComponent(artist)
          var exact = "https://lrclib.net/api/get?" + q
                    + (album ? "&album_name=" + encodeURIComponent(album) : "")
                    + (length > 0 ? "&duration=" + Math.round(length) : "")
          function store(lrc) {
              var parsed = root.parseLrc(lrc)
              var c = root._cache; c[key] = parsed; root._cache = c
              if (root._key === key) root.lyrics = parsed
          }
          _get(exact, function(r) {
              if (r && r.syncedLyrics) { store(r.syncedLyrics); return }
              // No exact match (album names and lengths differ between services): search.
              root._get("https://lrclib.net/api/search?" + q, function(list) {
                  var hit = null
                  if (Array.isArray(list))
                      for (var i = 0; i < list.length && !hit; i++) if (list[i].syncedLyrics) hit = list[i]
                  store(hit ? hit.syncedLyrics : "")
              })
          })
      }
  }
''
