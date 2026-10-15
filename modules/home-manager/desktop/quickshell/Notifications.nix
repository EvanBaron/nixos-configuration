{ ... }:
''
  pragma Singleton
  import Quickshell
  import Quickshell.Services.Notifications
  import QtQuick

  // The desktop's notification daemon (replaces swaync).
  // History lives in server.trackedNotifications; `toasts` holds what is currently shown as a pop-up.
  Singleton {
      id: root

      property bool dnd: false
      property bool centerOpen: false
      property int  unread: 0
      property var  toasts: []
      property var  times: ({})        // notification id → arrival time (the protocol carries none)
      property date now: new Date()    // ticks so relative times stay fresh

      // Transient notifications (e.g. niri's "Screenshot captured") toast but stay out of history.
      readonly property var history: server.trackedNotifications.values.filter(n => !n.transient).reverse()
      // Unread never exceeds what is still in history (dismissing a toast removes it).
      readonly property int unreadCount: Math.min(unread, history.length)

      signal clearRequested()

      onCenterOpenChanged: if (centerOpen) { unread = 0; toasts = [] }

      Timer { interval: 30000; running: true; repeat: true; onTriggered: root.now = new Date() }

      NotificationServer {
          id: server
          keepOnReload: true
          persistenceSupported: true
          actionsSupported: true
          imageSupported: true
          bodySupported: true
          bodyMarkupSupported: true
          bodyHyperlinksSupported: false

          onNotification: (n) => {
              var t = Object.assign({}, root.times)
              t[n.id] = new Date()
              root.times = t
              // Untracked notifications are destroyed as soon as this handler returns, which left
              // transient toasts empty; track every one and expire transient ones when their toast ends.
              n.tracked = true
              if (!root.centerOpen) {
                  if (!n.transient) root.unread++
                  if (!root.dnd || n.urgency === NotificationUrgency.Critical)
                      root.toasts = [n].concat(root.toasts).slice(0, 4)
              }
              n.closed.connect(() => root.toasts = root.toasts.filter(x => x !== n))
          }
      }

      // A toast timed out: hide it; history keeps it unless it was transient.
      function dropToast(n) {
          root.toasts = root.toasts.filter(x => x !== n)
          if (n.transient) n.expire()
      }

      // Toast lifetime in ms; 0 means it stays until dismissed.
      function timeoutFor(n) {
          if (n.urgency === NotificationUrgency.Critical) return 0
          if (n.expireTimeout > 0) return n.expireTimeout * 1000
          return n.urgency === NotificationUrgency.Low ? 2000 : 5000
      }

      function ago(n, now) {   // pass Notifications.now so bindings refresh
          var t = root.times[n.id]
          if (!t) return ""
          var s = Math.max(0, Math.floor(((now || root.now) - t) / 1000))
          if (s < 60) return "now"
          if (s < 3600) return Math.floor(s / 60) + " min ago"
          if (s < 86400) return Math.floor(s / 3600) + " h ago"
          return Math.floor(s / 86400) + " d ago"
      }

      function clearAll() {
          unread = 0
          clearRequested()
      }
  }
''
