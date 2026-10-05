import QtQuick
import QtQuick.Layouts
import Quickshell

FocusScope {
    id: root

    required property QtObject theme
    required property string label
    property string address: ""
    required property url iconSource
    property bool connected: false
    property bool connecting: false
    property string statusText: connected ? "Connected" : (connecting ? "Connecting..." : "")

    signal connectClicked()
    signal disconnectClicked()
    signal clicked()

    implicitHeight: 46
    activeFocusOnTab: enabled
    scale: tap.pressed ? theme.pressScale : 1
    Accessible.role: Accessible.Button
    Accessible.name: label + ". " + (connected ? "Connected" : "Not connected")
    Keys.onEnterPressed: root.clicked()
    Keys.onReturnPressed: root.clicked()
    Keys.onSpacePressed: root.clicked()

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radiusControl
        color: root.connected ? root.theme.alpha(root.theme.blue, 0.35) : (hover.hovered ? root.theme.alpha(root.theme.peach, 0.24) : root.theme.surfaceRaised)
        border.width: root.theme.borderWidth
        border.color: root.activeFocus ? root.theme.focus : root.theme.ink

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: root.theme.space3
            anchors.rightMargin: root.theme.space3
            spacing: root.theme.space2

            Image {
                Layout.preferredWidth: root.theme.iconSm
                Layout.preferredHeight: root.theme.iconSm
                source: root.iconSource
                sourceSize.width: root.theme.iconSm
                sourceSize.height: root.theme.iconSm
                fillMode: Image.PreserveAspectFit
                mipmap: true
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: root.label
                    color: root.theme.ink
                    elide: Text.ElideRight
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.textXs
                    font.weight: root.connected ? Font.Bold : Font.Medium
                }

                Text {
                    visible: root.statusText.length > 0 || root.address.length > 0
                    Layout.fillWidth: true
                    text: root.statusText.length > 0 ? root.statusText : root.address
                    color: root.connected ? root.theme.ink : root.theme.inkMuted
                    elide: Text.ElideRight
                    font.family: root.theme.fontFamily
                    font.pixelSize: 8
                    font.weight: root.connected ? Font.Bold : Font.Normal
                }
            }

            Rectangle {
                Layout.preferredWidth: 74
                Layout.preferredHeight: 24
                radius: root.theme.radiusControl
                color: root.connected ? root.theme.coral : root.theme.green
                border.width: 1
                border.color: root.theme.ink

                Text {
                    anchors.centerIn: parent
                    text: root.connecting ? "WAIT..." : (root.connected ? "DISCONNECT" : "CONNECT")
                    color: root.theme.ink
                    font.family: root.theme.fontFamily
                    font.pixelSize: 8
                    font.weight: Font.Bold
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.connected)
                            root.disconnectClicked();
                        else
                            root.connectClicked();
                    }
                }
            }
        }

        HoverHandler {
            id: hover
        }

        TapHandler {
            id: tap
            onTapped: root.clicked()
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.theme.motionFast
            easing.type: root.theme.easingStandard
        }
    }
}
