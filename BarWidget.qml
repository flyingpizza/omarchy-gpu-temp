import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

BarWidget {
  id: root
  moduleName: "daitos.gpu-temp"

  property var snapshot: ({ ok: false, ts: 0, gpus: [], hottest: null })

  readonly property int refreshSec: Math.max(1, parseInt(setting("refreshIntervalSec", 3), 10) || 3)
  readonly property string tempUnit: setting("tempUnit", "C")
  readonly property string collector: Model.fileUrlToPath(Qt.resolvedUrl("collect.py"))

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("snapshot" in target) target.snapshot = root.snapshot
  }

  function applySnapshot(raw) {
    var next = Model.parseSnapshot(raw)
    if (!next) return
    root.snapshot = next
    if (panelLoader.item && "snapshot" in panelLoader.item)
      panelLoader.item.snapshot = next
  }

  function refresh() {
    if (!collectProc.running) collectProc.running = true
  }

  function getColor(tempC) {
    if (tempC === null || isNaN(tempC)) return root.bar ? root.bar.foreground : "#ffffff"
    if (tempC <= 70) return root.bar ? root.bar.foreground : "#ffffff"
    if (tempC <= 80) return root.bar ? Color.accent : "#f0c040"
    return root.bar ? root.bar.urgent : "#ff4040"
  }

  function formatTemp(tempC) {
    return Model.formatTempFull(tempC, root.tempUnit)
  }

  function barTooltip() {
    var gpus = root.snapshot.gpus || []
    if (gpus.length === 0) return "No NVIDIA GPUs detected"
    return gpus.map(function(g) {
      return g.name + "  " + Model.formatTempFull(g.tempC, root.tempUnit)
    }).join("\n  ·  ")
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight
  visible: root.snapshot.gpus.length > 0

  onBarChanged: injectPanel()

  Process {
    id: collectProc
    command: ["python3", root.collector]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applySnapshot(text)
    }
  }

  Timer {
    interval: root.refreshSec * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  IpcHandler {
    target: "daitos.gpu-temp"
    function refresh(): void { root.broadcast("refresh") }
    function open(): void { root.broadcast("open") }
    function close(): void { root.broadcast("close") }
    function show(): void { root.broadcast("open") }
    function hide(): void { root.broadcast("close") }
    function toggle(): void { root.togglePanel() }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""
    labelVisible: false
    hasVisualContent: root.snapshot.gpus.length > 0
    tooltipText: root.barTooltip()
    horizontalMargin: 8.75
    verticalPadding: 8.75
    fixedWidth: Math.max(12, gpuRow.implicitWidth + scaledHorizontalMargin * 2)
    fixedHeight: Math.max(Style.bar.iconSlot, gpuRow.implicitHeight)
    useActiveColor: true

    onPressed: function(b) { root.togglePanel() }

    Row {
      id: gpuRow
      anchors.centerIn: parent
      spacing: Style.space(8)

      Repeater {
        model: root.snapshot.gpus

        Row {
          spacing: Style.space(5)

          Text {
            text: "🖥️"
            font.family: button.fontFamily
            font.pixelSize: button.fontSize * 0.8
            color: button.active && button.useActiveColor ? button.activeColor : button.foreground
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: modelData.name + "  " + Model.formatTempFull(modelData.tempC, root.tempUnit)
            color: getColor(modelData.tempC)
            font.family: button.fontFamily
            font.pixelSize: Style.font.body
            anchors.verticalCenter: parent.verticalCenter
          }
        }
      }
    }
  }
}
