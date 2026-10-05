import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root
  moduleName: "daitos.gpu-temp"
  ipcTarget: ""
  manageIpc: false

  property var snapshot: ({ ok: false, ts: 0, gpus: [], hottest: null })
  property var bar: null
  property var settings: ({})
  readonly property var barIdentity: root

  // Color/style properties (copied from hamsti.vitals pattern)
  readonly property color foreground: bar ? bar.foreground : Color.popups.text
  readonly property color accent: Color.accent
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color dim: Color.muted
  readonly property color track: Style.hoverFillFor(foreground, Color.accent)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property string tempUnit: setting("tempUnit", "C")

  // Color logic
  function getColor(tempC) {
    if (tempC === null || isNaN(tempC)) return root.dim
    if (tempC <= 70) return root.foreground
    if (tempC <= 80) return root.accent
    return root.urgent
  }

  // Panel content
  visible: true

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem || root
    owner: root.barIdentity || root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(320))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
    }

    Flickable {
      id: scroll
      anchors.fill: parent
      contentWidth: width
      contentHeight: column.implicitHeight
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      interactive: contentHeight > height

      Column {
        id: column
        width: scroll.width
        spacing: Style.space(8)

        // Title
        Text {
          text: "GPU Temperatures"
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.title
          font.bold: true
        }

        // GPU LIST — uses Repeater with direct modelData access
        Repeater {
          model: root.snapshot.gpus
          Row {
            anchors.centerIn: parent
            spacing: Style.space(5)

            Text {
              text: "🖥️"
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              color: getColor(modelData.tempC)
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              text: modelData.name
              color: getColor(modelData.tempC)
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              text: "  " + Model.formatTempFull(modelData.tempC, root.tempUnit)
              color: getColor(modelData.tempC)
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              anchors.verticalCenter: parent.verticalCenter
            }
            // Meter track
            Rectangle {
              width: Math.max(2, (modelData.tempC / 105) * 60)
              height: 4
              radius: 2
              color: root.track
              anchors.verticalCenter: parent.verticalCenter
            }
            // Meter fill
            Rectangle {
              width: Math.max(2, (modelData.tempC / 105) * 60)
              height: 4
              radius: 2
              color: getColor(modelData.tempC)
              anchors.verticalCenter: parent.verticalCenter
            }
          }
        }

        // Footer
        Text {
          width: parent.width
          text: "Click to close  ·  Click bar widget to refresh"
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
        }
      }
    }
  }
}