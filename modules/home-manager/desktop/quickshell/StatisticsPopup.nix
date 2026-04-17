{ ... }:
''
  import Quickshell
  import Quickshell.Wayland
  import Quickshell.Io
  import QtQuick
  import QtQuick.Layouts
  import "."

  PanelWindow {
      id: statisticsPopup
      anchors.top: true
      anchors.right: true
      implicitWidth:  300
      implicitHeight: mainColumn.implicitHeight + 20
      color: "transparent"
      visible: false

      WlrLayershell.namespace:     "statistics-popup"
      WlrLayershell.layer:         WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      WlrLayershell.exclusionMode: ExclusionMode.Ignore

      WlrLayershell.margins.top:   30
      WlrLayershell.margins.right: 60

      property real loadAverage1:  0
      property real loadAverage5:  0
      property real loadAverage15: 0
      property int  processesTotal: 0
      property int  processesRunning:   0
      property string uptimeString: ""
      property string hostname:  ""
      property string osName:    ""
      property string kernelVersion: ""
      property real receiveKilobytes: 0
      property real transmitKilobytes: 0
      property real _prevRx: 0
      property real _prevTx: 0
      property real _prevTs: 0

      property var cpuHistory:  [20,35,28,45,60,42,55,38,62,48,70,52,44,66,58,72,50,63,57,65]
      property var temperatureHistory: [45,47,46,48,50,49,51,50,52,51,53,52,54,53,55,54,56,55,57,58]
      property var memoryHistory:  [40,42,41,43,44,42,45,43,46,44,47,45,48,46,47,45,49,47,48,50]
      function pushHistory(arr, val) { var a=arr.slice(1); a.push(val); return a }

      Connections {
          target: SystemStats
          function onCpuPercentageChanged()  { statisticsPopup.cpuHistory  = statisticsPopup.pushHistory(statisticsPopup.cpuHistory,  SystemStats.cpuPercentage) }
          function onCpuTemperatureChanged() { statisticsPopup.temperatureHistory = statisticsPopup.pushHistory(statisticsPopup.temperatureHistory, SystemStats.cpuTemperature) }
          function onMemoryPercentageChanged()  { statisticsPopup.memoryHistory  = statisticsPopup.pushHistory(statisticsPopup.memoryHistory,  SystemStats.memoryPercentage) }
      }
      Timer { interval:200; running:statisticsPopup.visible; repeat:true
          onTriggered: {
              statisticsPopup.cpuHistory  = statisticsPopup.pushHistory(statisticsPopup.cpuHistory,  Math.max(2,Math.min(98,statisticsPopup.cpuHistory[statisticsPopup.cpuHistory.length-1]+(Math.random()-.48)*12)))
              statisticsPopup.temperatureHistory = statisticsPopup.pushHistory(statisticsPopup.temperatureHistory, Math.max(2,Math.min(98,statisticsPopup.temperatureHistory[statisticsPopup.temperatureHistory.length-1]+(Math.random()-.48)*5)))
              statisticsPopup.memoryHistory  = statisticsPopup.pushHistory(statisticsPopup.memoryHistory,  Math.max(2,Math.min(98,statisticsPopup.memoryHistory[statisticsPopup.memoryHistory.length-1]+(Math.random()-.48)*6)))
          }
      }

      FileView { id:loadAverageFileView; path:"/proc/loadavg"; watchChanges:true
          onFileChanged: reload()
          onTextChanged: {
              var t=text(); if(!t||!t.trim()) return
              var p=t.trim().split(/\s+/)
              statisticsPopup.loadAverage1  = parseFloat(p[0])||0
              statisticsPopup.loadAverage5  = parseFloat(p[1])||0
              statisticsPopup.loadAverage15 = parseFloat(p[2])||0
              var tasks=(p[3]||"0/0").split("/")
              statisticsPopup.processesRunning   = parseInt(tasks[0])||0
              statisticsPopup.processesTotal = parseInt(tasks[1])||0
          }
      }
      Timer { interval:3000; running:statisticsPopup.visible; repeat:true; triggeredOnStart:true
          onTriggered: loadAverageFileView.reload() }

      FileView { id:uptimeFileView; path:"/proc/uptime"; watchChanges:false
          onTextChanged: {
              var t=text(); if(!t) return
              var secs=Math.floor(parseFloat(t.trim().split(/\s+/)[0])||0)
              var d=Math.floor(secs/86400); secs%=86400
              var h=Math.floor(secs/3600);  secs%=3600
              var m=Math.floor(secs/60)
              statisticsPopup.uptimeString = d>0?(d+"d "+h+"h "+m+"m"):h>0?(h+"h "+m+"m"):(m+"m")
          }
      }
      Timer { interval:30000; running:statisticsPopup.visible; repeat:true; triggeredOnStart:true
          onTriggered: uptimeFileView.reload() }

      FileView { id:networkFileView; path:"/proc/net/dev"; watchChanges:true
          onFileChanged: reload()
          onTextChanged: {
              var t=text(); if(!t) return
              var now=Date.now()
              var elapsed=statisticsPopup._prevTs>0?Math.max(0.1,(now-statisticsPopup._prevTs)/1000.0):1.0
              statisticsPopup._prevTs=now
              var lines=t.split("\n"); var rx=0,tx=0
              for(var i=0;i<lines.length;i++){
                  var l=lines[i].trim(); if(!l) continue
                  var ci=l.lastIndexOf(":"); if(ci<0) continue
                  if(l.substring(0,ci).trim()==="lo") continue
                  var nums=l.substring(ci+1).trim().split(/\s+/)
                  if(nums.length<9) continue
                  rx+=parseFloat(nums[0])||0; tx+=parseFloat(nums[8])||0
              }
              if(statisticsPopup._prevRx>0&&rx>0&&elapsed>0){
                  statisticsPopup.receiveKilobytes=Math.max(0,(rx-statisticsPopup._prevRx)/1024.0/elapsed)
                  statisticsPopup.transmitKilobytes=Math.max(0,(tx-statisticsPopup._prevTx)/1024.0/elapsed)
              }
              if(rx>0){statisticsPopup._prevRx=rx; statisticsPopup._prevTx=tx}
          }
      }
      Timer { interval:600; running:statisticsPopup.visible; repeat:true; triggeredOnStart:true
          onTriggered: networkFileView.reload() }

      property var diskList: []
      Process { id:diskProcess
          command:["sh","-c","df -h 2>/dev/null | awk 'NR>1 && ($1~/^\/dev\//) {print $6,$2,$3,$4,$5}'"]
          stdout: SplitParser {
              property var _tmp: []
              onRead: function(d) {
                  var p=d.trim().split(/\s+/)
                  if(p.length<5) return
                  _tmp.push({mount:p[0],total:p[1],used:p[2],free:p[3],percentage:parseInt(p[4].replace("%",""))||0})
              }
              Component.onCompleted: _tmp=[]
          }
          onRunningChanged: {
              if(!running) {
                  if(diskProcess.stdout._tmp.length===0) {
                      diskProcessFallback.running=false; diskProcessFallback.running=true
                  } else {
                      statisticsPopup.diskList=diskProcess.stdout._tmp.slice()
                      diskProcess.stdout._tmp=[]
                  }
              } else {
                  diskProcess.stdout._tmp=[]
              }
          }
          Component.onCompleted: running=true
      }
      Process { id:diskProcessFallback; command:["df","-h","/"]
          property bool _hdr: true
          stdout: SplitParser {
              onRead: function(d) {
                  if(diskProcessFallback._hdr){diskProcessFallback._hdr=false;return}
                  var p=d.trim().split(/\s+/)
                  if(p.length<6) return
                  statisticsPopup.diskList=[{mount:p[5]||"/",total:p[1],used:p[2],free:p[3],percentage:parseInt(p[4].replace("%",""))||0}]
              }
          }
          onRunningChanged: if(!running) _hdr=true
      }
      Timer { interval:15000; running:statisticsPopup.visible; repeat:true; triggeredOnStart:true
          onTriggered:{ diskProcess.running=false; diskProcess.running=true } }

      property string diskTotal: diskList.length>0?diskList[0].total:"?"
      property string diskUsed:  diskList.length>0?diskList[0].used:"?"
      property string diskFree:  diskList.length>0?diskList[0].free:"?"
      property int    diskPercentage:   diskList.length>0?diskList[0].percentage:0

      Process { id:hostnameProcess; command:["hostname"]
          stdout: SplitParser { onRead: function(d){ statisticsPopup.hostname=d.trim() } }
          Component.onCompleted: running=true }

      Process { id:kernelProcess; command:["uname","-r"]
          stdout: SplitParser { onRead: function(d){ statisticsPopup.kernelVersion=d.trim().split("-")[0] } }
          Component.onCompleted: running=true }

      Process { id:osProcess; command:["sh","-c","grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//;s/\"//g;s/—//g;s/ - //g'"]
          stdout: SplitParser { onRead: function(d){ statisticsPopup.osName=d.trim().replace(/[\u2014\u2013\u2012]/g,"").trim() } }
          Component.onCompleted: running=true }

      function formatNetworkSpeed(kilobytes) {
          if(kilobytes>=1024) return (kilobytes/1024).toFixed(1)+" MB/s"
          if(kilobytes>=1)    return Math.round(kilobytes)+" KB/s"
          return "0 B/s"
      }
      function createIcon(paths,color,sz) {
          return "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='"+(sz||16)+"' height='"+(sz||16)+"' viewBox='0 0 24 24' fill='none' stroke='"+color+"' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>"+paths+"</svg>"
      }

      readonly property string iconCpu:   "<rect x='4' y='4' width='16' height='16' rx='2'/><rect x='8' y='8' width='8' height='8' rx='1'/><path d='M12 2v2'/><path d='M12 20v2'/><path d='M2 12h2'/><path d='M20 12h2'/>"
      readonly property string iconThermometer: "<path d='M14 14.76V3.5a2.5 2.5 0 0 0-5 0v11.26a4.5 4.5 0 1 0 5 0z'/>"
      readonly property string iconMemory:   "<rect x='6' y='2' width='12' height='20' rx='2'/><path d='M10 7h4'/><path d='M10 12h4'/><path d='M10 17h4'/><path d='M4 7h2'/><path d='M4 12h2'/><path d='M4 17h2'/><path d='M18 7h2'/><path d='M18 12h2'/><path d='M18 17h2'/>"
      readonly property string iconDownload:  "<path d='M12 5v14'/><path d='m19 12-7 7-7-7'/>"
      readonly property string iconUpload:    "<path d='M12 19V5'/><path d='m5 12 7-7 7 7'/>"
      readonly property string iconDisk:  "<ellipse cx='12' cy='5' rx='9' ry='3'/><path d='M3 5v14a9 3 0 0 0 18 0V5'/><path d='M3 12a9 3 0 0 0 18 0'/>"

      Item { anchors.fill:parent; opacity:0.96
          Rectangle { anchors.fill:parent; color:Colors.bg; radius:10
              Rectangle { anchors.top:parent.top; anchors.left:parent.left; anchors.right:parent.right; height:10; color:Colors.bg }
          }
      }

      ColumnLayout {
          id: mainColumn
          anchors.left:     parent.left
          anchors.right:    parent.right
          anchors.top:      parent.top
          anchors.margins:  10
          anchors.topMargin: 10
          spacing: 6

          Rectangle { Layout.fillWidth:true; height:168; radius:10; color:Colors.bgAlt
              Repeater { model:2; Rectangle { x:10; y:56+index*54; width:parent.width-20; height:1; color:Colors.border; opacity:0.25 } }
              Column {
                  anchors.left:      parent.left
                  anchors.right:     parent.right
                  anchors.top:       parent.top
                  anchors.topMargin: 4
                  anchors.leftMargin: 10
                  anchors.rightMargin: 10
                  spacing:0

                  Item { width:parent.width; height:54
                      Rectangle{x:0;anchors.verticalCenter:parent.verticalCenter;width:30;height:30;radius:6;color:Colors.highlight
                          Image{anchors.centerIn:parent;width:16;height:16;smooth:true;source:statisticsPopup.createIcon(statisticsPopup.iconCpu,encodeURIComponent(Colors.fg),16)}}
                      Text{x:40;anchors.verticalCenter:parent.verticalCenter;text:Math.round(SystemStats.cpuPercentage)+"%";color:Colors.fg;font.family:"Fira Sans";font.pixelSize:15;font.weight:Font.Medium;width:46}
                      Canvas{x:88;y:7;width:parent.width-88;height:40;property var hist:statisticsPopup.cpuHistory;onHistChanged:requestPaint()
                          onPaint:{var c=getContext("2d");c.clearRect(0,0,width,height);c.strokeStyle=Colors.base0D;c.lineWidth=1.8;c.lineJoin="round";c.beginPath();for(var i=0;i<hist.length;i++){var px=i/(hist.length-1)*width,py=height-(hist[i]/100)*height*.85;i?c.lineTo(px,py):c.moveTo(px,py)}c.stroke();c.fillStyle=Colors.base0D;c.beginPath();c.arc(width,height-(hist[hist.length-1]/100)*height*.85,3,0,Math.PI*2);c.fill()}}
                  }
                  Item { width:parent.width; height:54
                      Rectangle{x:0;anchors.verticalCenter:parent.verticalCenter;width:30;height:30;radius:6;color:Colors.highlight
                          Image{anchors.centerIn:parent;width:16;height:16;smooth:true;source:statisticsPopup.createIcon(statisticsPopup.iconThermometer,encodeURIComponent(Colors.fg),16)}}
                      Text{x:40;anchors.verticalCenter:parent.verticalCenter;text:SystemStats.cpuTemperature>0?Math.round(SystemStats.cpuTemperature)+"°":"--°";color:Colors.fg;font.family:"Fira Sans";font.pixelSize:15;font.weight:Font.Medium;width:46}
                      Canvas{x:88;y:7;width:parent.width-88;height:40;property var hist:statisticsPopup.temperatureHistory;onHistChanged:requestPaint()
                          onPaint:{var c=getContext("2d");c.clearRect(0,0,width,height);c.strokeStyle=Colors.base0A;c.lineWidth=1.8;c.lineJoin="round";c.beginPath();for(var i=0;i<hist.length;i++){var px=i/(hist.length-1)*width,py=height-(hist[i]/100)*height*.85;i?c.lineTo(px,py):c.moveTo(px,py)}c.stroke();c.fillStyle=Colors.base0A;c.beginPath();c.arc(width,height-(hist[hist.length-1]/100)*height*.85,3,0,Math.PI*2);c.fill()}}
                  }
                  Item { width:parent.width; height:54
                      Rectangle{x:0;anchors.verticalCenter:parent.verticalCenter;width:30;height:30;radius:6;color:Colors.highlight
                          Image{anchors.centerIn:parent;width:16;height:16;smooth:true;source:statisticsPopup.createIcon(statisticsPopup.iconMemory,encodeURIComponent(Colors.fg),16)}}
                      Text{x:40;anchors.verticalCenter:parent.verticalCenter;text:SystemStats.memoryGigabytes.toFixed(1)+"G";color:Colors.fg;font.family:"Fira Sans";font.pixelSize:15;font.weight:Font.Medium;width:46}
                      Canvas{x:88;y:7;width:parent.width-88;height:40;property var hist:statisticsPopup.memoryHistory;onHistChanged:requestPaint()
                          onPaint:{var c=getContext("2d");c.clearRect(0,0,width,height);c.strokeStyle=Colors.base0E;c.lineWidth=1.8;c.lineJoin="round";c.beginPath();for(var i=0;i<hist.length;i++){var px=i/(hist.length-1)*width,py=height-(hist[i]/100)*height*.85;i?c.lineTo(px,py):c.moveTo(px,py)}c.stroke();c.fillStyle=Colors.base0E;c.beginPath();c.arc(width,height-(hist[hist.length-1]/100)*height*.85,3,0,Math.PI*2);c.fill()}}
                  }
              }
          }

          Rectangle { Layout.fillWidth:true; height:64; radius:10; color:Colors.bgAlt
              Item {
                  anchors.fill: parent
                  anchors.leftMargin: 14
                  anchors.rightMargin: 14

                  Column {
                      anchors.left: parent.left
                      anchors.verticalCenter: parent.verticalCenter
                      spacing: 3
                      Row { spacing:6
                          Image{width:14;height:14;smooth:true;anchors.verticalCenter:parent.verticalCenter;source:statisticsPopup.createIcon(statisticsPopup.iconDownload,encodeURIComponent(Colors.base0B),14)}
                          Text{text:statisticsPopup.formatNetworkSpeed(statisticsPopup.receiveKilobytes);color:Colors.fg;font.family:"Fira Sans";font.pixelSize:16;font.weight:Font.Medium;anchors.verticalCenter:parent.verticalCenter}
                      }
                      Text{text:"Download";color:Colors.fg;font.family:"Fira Sans";font.pixelSize:10}
                  }

                  Rectangle { width:1; height:40; color:Colors.border; opacity:0.4; anchors.centerIn:parent }

                  Column {
                      anchors.right: parent.right
                      anchors.verticalCenter: parent.verticalCenter
                      spacing: 3
                      Row { spacing:6; layoutDirection:Qt.RightToLeft
                          Image{width:14;height:14;smooth:true;anchors.verticalCenter:parent.verticalCenter;source:statisticsPopup.createIcon(statisticsPopup.iconUpload,encodeURIComponent(Colors.base09),14)}
                          Text{text:statisticsPopup.formatNetworkSpeed(statisticsPopup.transmitKilobytes);color:Colors.fg;font.family:"Fira Sans";font.pixelSize:16;font.weight:Font.Medium;anchors.verticalCenter:parent.verticalCenter}
                      }
                      Text{text:"Upload";color:Colors.fg;font.family:"Fira Sans";font.pixelSize:11;anchors.right:parent.right}
                  }
              }
          }

          Repeater {
              model: statisticsPopup.diskList.length > 0 ? statisticsPopup.diskList : [{mount:"/",total:"",used:"",free:"",percentage:0}]
              delegate: Rectangle {
                  required property var modelData
                  Layout.fillWidth: true; height: 62; radius: 10; color: Colors.bgAlt
                  Item {
                      anchors.fill: parent
                      anchors.leftMargin: 14; anchors.rightMargin: 14
                      anchors.topMargin: 10; anchors.bottomMargin: 10

                      Row {
                          anchors.top: parent.top
                          anchors.left: parent.left
                          anchors.right: parent.right
                          spacing: 6
                          Image { width:13; height:13; smooth:true; anchors.verticalCenter:parent.verticalCenter
                              source: statisticsPopup.createIcon(statisticsPopup.iconDisk, encodeURIComponent(Colors.fgAlt), 13) }
                          Text { text: modelData.mount; color:Colors.fg; font.family:"Fira Sans"; font.pixelSize:13; font.weight:Font.Medium; anchors.verticalCenter:parent.verticalCenter }
                          Item { width:1; height:1; Layout.fillWidth:true }
                          Text { text: modelData.used+" / "+modelData.total; color:Colors.fg; font.family:"Fira Sans"; font.pixelSize:12; anchors.verticalCenter:parent.verticalCenter }
                      }

                      Rectangle {
                          anchors.bottom: parent.bottom
                          anchors.left: parent.left
                          anchors.right: parent.right
                          height: 6; radius: 3; color: Colors.highlight
                          Rectangle {
                              width: parent.width * Math.min(modelData.percentage, 100) / 100
                              height: parent.height; radius: 3; color: Colors.fgAlt
                              Behavior on width { NumberAnimation { duration: 600 } }
                          }
                          Text { anchors.right:parent.right; anchors.rightMargin:4; anchors.verticalCenter:parent.verticalCenter
                              text: modelData.percentage+"%"; color:Colors.fg; font.family:"Fira Sans"; font.pixelSize:10; font.weight:Font.Bold }
                      }
                  }
              }
          }

          Rectangle { Layout.fillWidth:true; height:58; radius:10; color:Colors.bgAlt
              Item {
                  anchors.fill: parent
                  anchors.leftMargin: 14
                  anchors.rightMargin: 14

                  Column {
                      anchors.left: parent.left
                      anchors.verticalCenter: parent.verticalCenter
                      spacing: 4
                      Text{text:"Load Average";color:Colors.fg;font.family:"Fira Sans";font.pixelSize:10}
                      Row { spacing:14
                          Column { spacing:1
                              Text{text:statisticsPopup.loadAverage1.toFixed(2);color:Colors.fg;font.family:"Fira Sans";font.pixelSize:16;font.weight:Font.Medium}
                              Text{text:"1 min";color:Colors.fgAlt;font.family:"Fira Sans";font.pixelSize:10}
                          }
                          Column { spacing:1
                              Text{text:statisticsPopup.loadAverage5.toFixed(2);color:Colors.fg;font.family:"Fira Sans";font.pixelSize:16}
                              Text{text:"5 min";color:Colors.fgAlt;font.family:"Fira Sans";font.pixelSize:10}
                          }
                          Column { spacing:1
                              Text{text:statisticsPopup.loadAverage15.toFixed(2);color:Colors.fg;font.family:"Fira Sans";font.pixelSize:16}
                              Text{text:"15 min";color:Colors.fgAlt;font.family:"Fira Sans";font.pixelSize:10}
                          }
                      }
                  }

                  Column {
                      anchors.right: parent.right
                      anchors.verticalCenter: parent.verticalCenter
                      spacing: 4
                      Text{text:"Uptime";color:Colors.base03;font.family:"Fira Sans";font.pixelSize:11;anchors.right:parent.right}
                      Text{text:statisticsPopup.uptimeString||"";color:Colors.fg;font.family:"Fira Sans";font.pixelSize:16;font.weight:Font.Medium}
                  }
              }
          }

          Rectangle { Layout.fillWidth:true; height:62; radius:10; color:Colors.bgAlt
              Item {
                  anchors.fill: parent
                  anchors.leftMargin: 14
                  anchors.rightMargin: 14

                  Column {
                      anchors.left: parent.left
                      anchors.verticalCenter: parent.verticalCenter
                      spacing: 3
                      Text{text:statisticsPopup.hostname||"";color:Colors.fg;font.family:"Fira Sans";font.pixelSize:16;font.weight:Font.Medium}
                      Text{text:statisticsPopup.osName||"Linux";color:Colors.fg;font.family:"Fira Sans";font.pixelSize:13}
                  }

                  Column {
                      anchors.right: parent.right
                      anchors.verticalCenter: parent.verticalCenter
                      spacing: 3
                      Text{text:"Kernel";color:Colors.base03;font.family:"Fira Sans";font.pixelSize:11;anchors.right:parent.right}
                      Text{text:statisticsPopup.kernelVersion||"";color:Colors.fg;font.family:"Fira Sans";font.pixelSize:15;font.weight:Font.Medium}
                  }
              }
          }
      }
  }
''
