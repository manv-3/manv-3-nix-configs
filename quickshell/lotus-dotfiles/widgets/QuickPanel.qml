import "../components" as Ui
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

FocusScope {
    id: root

    required property QtObject theme
    required property QtObject clockService
    required property QtObject audioService
    required property QtObject networkService
    required property QtObject bluetoothService
    required property QtObject notificationService
    required property QtObject brightnessService
    required property QtObject systemStats
    required property QtObject calendarService
    required property QtObject sessionService
    required property QtObject attentionService
    property bool powerMenuOpen: false
    property bool bluetoothMenuOpen: false
    property string pendingAction: ""
    property string pendingLabel: ""
    property color pendingAccent: theme.coral

    signal closeRequested()
    signal notificationsRequested()

    function resetTransientState() {
        powerMenuOpen = false;
        bluetoothMenuOpen = false;
        pendingAction = "";
        pendingLabel = "";
        pendingAccent = theme.coral;
        calendarService.goToToday();
    }

    function choosePowerAction(action, label, accent) {
        pendingAction = action;
        pendingLabel = label;
        pendingAccent = accent || theme.coral;
    }

    function confirmPowerAction() {
        if (pendingAction.length === 0)
            return ;

        const action = pendingAction;
        resetTransientState();
        closeRequested();
        sessionService.runAction(action);
    }

    implicitWidth: theme.quickPanelWidth
    implicitHeight: panelColumn.implicitHeight + theme.space4 * 2 + theme.shadowOffset
    focus: true
    Keys.onEscapePressed: {
        if (root.pendingAction.length > 0) {
            root.pendingAction = "";
            root.pendingLabel = "";
        } else if (root.powerMenuOpen) {
            root.powerMenuOpen = false;
        } else {
            root.closeRequested();
        }
    }

    Ui.RaisedSurface {
        anchors.fill: parent
        theme: root.theme
        fill: root.theme.surface
        surfaceRadius: root.theme.radiusPanel
        padding: root.theme.space4

        ColumnLayout {
            id: panelColumn

            anchors.fill: parent
            spacing: root.theme.space3

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                spacing: root.theme.space3

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: "Quick controls"
                        color: root.theme.ink
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.textLg
                        font.weight: Font.Bold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: Qt.formatDateTime(root.clockService.now, "dddd, MMMM d")
                        color: root.theme.inkMuted
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.textXs
                    }

                }

                Ui.IconButton {
                    theme: root.theme
                    controlSize: 34
                    iconSource: Quickshell.shellDir + "/assets/icons/power.svg"
                    accessibleName: root.powerMenuOpen ? "Close session actions" : "Open session actions"
                    fill: root.powerMenuOpen ? root.theme.coral : root.theme.surfaceRaised
                    raised: true
                    onClicked: {
                        root.powerMenuOpen = !root.powerMenuOpen;
                        root.pendingAction = "";
                        root.pendingLabel = "";
                    }
                }

            }

            Rectangle {
                id: sessionCard
                visible: root.powerMenuOpen
                Layout.fillWidth: true
                implicitHeight: root.powerMenuOpen ? (root.pendingAction.length === 0 ? 76 : 64) : 0
                Layout.preferredHeight: implicitHeight
                radius: root.theme.radiusCard
                color: root.theme.surfaceMuted
                border.width: root.theme.borderWidth
                border.color: root.theme.ink

                RowLayout {
                    visible: root.pendingAction.length === 0
                    anchors.fill: parent
                    anchors.margins: root.theme.space2
                    spacing: 6

                    Repeater {
                        model: [
                            { action: "lock", label: "Lock", question: "Lock the session?", icon: "lock.svg", accent: root.theme.green },
                            { action: "suspend", label: "Sleep", question: "Suspend the computer?", icon: "suspend.svg", accent: root.theme.blue },
                            { action: "logout", label: "Logout", question: "Log out of Hyprland?", icon: "logout.svg", accent: root.theme.lilac },
                            { action: "restart", label: "Reboot", question: "Restart the computer?", icon: "restart.svg", accent: root.theme.gold },
                            { action: "poweroff", label: "Shutdown", question: "Shut down the computer?", icon: "power.svg", accent: root.theme.coral }
                        ]

                        FocusScope {
                            id: tileScope
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            activeFocusOnTab: true
                            Accessible.role: Accessible.Button
                            Accessible.name: modelData.label + ". " + modelData.question
                            Keys.onEnterPressed: root.choosePowerAction(modelData.action, modelData.question, modelData.accent)
                            Keys.onReturnPressed: root.choosePowerAction(modelData.action, modelData.question, modelData.accent)
                            Keys.onSpacePressed: root.choosePowerAction(modelData.action, modelData.question, modelData.accent)

                            Rectangle {
                                id: tileFace
                                anchors.fill: parent
                                radius: root.theme.radiusControl
                                color: tileTap.pressed ? root.theme.alpha(modelData.accent, 0.4) : (tileHover.hovered ? root.theme.alpha(modelData.accent, 0.25) : root.theme.surfaceRaised)
                                border.width: tileScope.activeFocus ? root.theme.borderWidth : 1
                                border.color: tileScope.activeFocus ? root.theme.focus : root.theme.ink

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 3

                                    Image {
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.preferredWidth: root.theme.iconMd
                                        Layout.preferredHeight: root.theme.iconMd
                                        source: Quickshell.shellDir + "/assets/icons/" + modelData.icon
                                        sourceSize.width: root.theme.iconMd
                                        sourceSize.height: root.theme.iconMd
                                        fillMode: Image.PreserveAspectFit
                                        mipmap: true
                                    }

                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: modelData.label
                                        font.family: root.theme.fontFamily
                                        font.pixelSize: 9
                                        font.weight: Font.Bold
                                        color: root.theme.ink
                                    }
                                }

                                HoverHandler { id: tileHover }
                                TapHandler {
                                    id: tileTap
                                    onTapped: root.choosePowerAction(modelData.action, modelData.question, modelData.accent)
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    visible: root.pendingAction.length > 0
                    anchors.fill: parent
                    anchors.margins: root.theme.space2
                    spacing: root.theme.space2

                    Text {
                        Layout.fillWidth: true
                        text: root.pendingLabel
                        wrapMode: Text.WordWrap
                        color: root.theme.ink
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.textXs
                        font.weight: Font.DemiBold
                    }

                    Ui.PixelButton {
                        Layout.preferredWidth: 76
                        theme: root.theme
                        label: "Cancel"
                        fill: root.theme.surfaceRaised
                        onClicked: {
                            root.pendingAction = "";
                            root.pendingLabel = "";
                        }
                    }

                    Ui.PixelButton {
                        Layout.preferredWidth: 76
                        theme: root.theme
                        label: "Confirm"
                        fill: root.pendingAccent
                        onClicked: root.confirmPowerAction()
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: root.theme.space2

                Ui.StatChip {
                    theme: root.theme
                    iconSource: Quickshell.shellDir + "/assets/icons/cpu.svg"
                    label: "CPU"
                    value: root.systemStats.cpuLoading ? "..." : (root.systemStats.cpuError ? "!" : root.systemStats.cpuUsage + "%")
                    accent: root.theme.peach
                }

                Ui.StatChip {
                    theme: root.theme
                    iconSource: Quickshell.shellDir + "/assets/icons/memory.svg"
                    label: "RAM"
                    value: root.systemStats.memoryLoading ? "..." : (root.systemStats.memoryError ? "!" : root.systemStats.memoryUsage + "%")
                    accent: root.theme.blue
                }

                Ui.StatChip {
                    visible: root.systemStats.batteryAvailable
                    theme: root.theme
                    iconSource: Quickshell.shellDir + "/assets/icons/battery.svg"
                    label: "BAT"
                    value: root.systemStats.batteryPercent + "%"
                    accent: root.theme.green
                }

                Item {
                    Layout.fillWidth: true
                }

            }

            RowLayout {
                Layout.fillWidth: true
                spacing: root.theme.space2

                Ui.ControlTile {
                    Layout.fillWidth: true
                    theme: root.theme
                    iconSource: Quickshell.shellDir + "/assets/icons/coffee.svg"
                    label: "Caffeine"
                    status: root.attentionService.caffeineStatusText
                    checked: root.attentionService.caffeineEnabled
                    accent: root.theme.gold
                    onClicked: root.attentionService.toggleCaffeine()
                }

                Ui.ControlTile {
                    Layout.fillWidth: true
                    theme: root.theme
                    iconSource: Quickshell.shellDir + "/assets/icons/" + (root.notificationService.quietMode ? "bell-off.svg" : "bell.svg")
                    label: "Quiet mode"
                    status: root.notificationService.quietMode ? "Critical alerts only" : "Notifications on"
                    checked: root.notificationService.quietMode
                    accent: root.theme.lilac
                    onClicked: root.notificationService.toggleQuietMode()
                }

                Item {
                    Layout.fillWidth: true
                }

            }

            RowLayout {
                visible: root.attentionService.caffeineEnabled
                Layout.fillWidth: true
                spacing: root.theme.space2

                Text {
                    Layout.fillWidth: true
                    text: "Keep awake for"
                    color: root.theme.inkMuted
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.textXs
                    font.weight: Font.DemiBold
                }

                Ui.PixelButton {
                    Layout.preferredWidth: 60
                    theme: root.theme
                    label: "30m"
                    fill: root.theme.surfaceRaised
                    onClicked: root.attentionService.startCaffeine(30)
                }

                Ui.PixelButton {
                    Layout.preferredWidth: 60
                    theme: root.theme
                    label: "1h"
                    fill: root.theme.gold
                    onClicked: root.attentionService.startCaffeine(60)
                }

                Ui.PixelButton {
                    Layout.preferredWidth: 60
                    theme: root.theme
                    label: "2h"
                    fill: root.theme.surfaceRaised
                    onClicked: root.attentionService.startCaffeine(120)
                }

            }

            RowLayout {
                Layout.fillWidth: true
                spacing: root.theme.space2

                Ui.ControlTile {
                    Layout.fillWidth: true
                    theme: root.theme
                    iconSource: Quickshell.shellDir + "/assets/icons/" + (root.networkService.wifiEnabled ? "wifi.svg" : "wifi-off.svg")
                    label: "Wi-Fi"
                    status: root.networkService.networkName
                    checked: root.networkService.wifiEnabled
                    enabled: root.networkService.wifiAvailable
                    accent: root.theme.green
                    onClicked: root.networkService.toggleWifi()
                }

                Ui.ControlTile {
                    Layout.fillWidth: true
                    theme: root.theme
                    iconSource: Quickshell.shellDir + "/assets/icons/" + (root.bluetoothService.enabled ? "bluetooth.svg" : "bluetooth-off.svg")
                    label: "Bluetooth"
                    status: root.bluetoothService.connectedCount > 0 ? root.bluetoothService.connectedName : (root.bluetoothService.enabled ? "On" : "Off")
                    checked: root.bluetoothService.enabled || root.bluetoothMenuOpen
                    enabled: root.bluetoothService.available
                    accent: root.theme.blue
                    onClicked: {
                        if (!root.bluetoothService.enabled) {
                            root.bluetoothService.setEnabled(true);
                            root.bluetoothMenuOpen = true;
                        } else {
                            root.bluetoothMenuOpen = !root.bluetoothMenuOpen;
                        }
                    }
                }

                Ui.ControlTile {
                    Layout.fillWidth: true
                    theme: root.theme
                    iconSource: Quickshell.shellDir + "/assets/icons/bell.svg"
                    label: "Notify"
                    status: root.notificationService.count + " saved"
                    checked: root.notificationService.count > 0
                    accent: root.theme.pink
                    onClicked: root.notificationsRequested()
                }

            }

            Rectangle {
                visible: root.bluetoothMenuOpen
                Layout.fillWidth: true
                Layout.preferredHeight: btColumn.implicitHeight + root.theme.space3 * 2
                radius: root.theme.radiusCard
                color: root.theme.surfaceMuted
                border.width: root.theme.borderWidth
                border.color: root.theme.ink

                ColumnLayout {
                    id: btColumn

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: root.theme.space3
                    spacing: root.theme.space2

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: root.theme.space2

                        Text {
                            Layout.fillWidth: true
                            text: "Bluetooth devices"
                            color: root.theme.ink
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.textXs
                            font.weight: Font.Bold
                        }

                        Ui.PixelButton {
                            Layout.preferredWidth: 68
                            theme: root.theme
                            label: root.bluetoothService.enabled ? "Turn Off" : "Turn On"
                            fill: root.bluetoothService.enabled ? root.theme.surfaceRaised : root.theme.green
                            onClicked: root.bluetoothService.toggleEnabled()
                        }

                        Ui.PixelButton {
                            visible: root.bluetoothService.enabled
                            Layout.preferredWidth: 64
                            theme: root.theme
                            label: root.bluetoothService.discovering ? "Scanning" : "Scan"
                            fill: root.bluetoothService.discovering ? root.theme.peach : root.theme.surfaceRaised
                            onClicked: root.bluetoothService.toggleDiscovery()
                        }
                    }

                    Text {
                        visible: !root.bluetoothService.enabled
                        Layout.fillWidth: true
                        Layout.topMargin: root.theme.space2
                        Layout.bottomMargin: root.theme.space2
                        text: "Bluetooth is powered off. Turn it on to connect devices."
                        color: root.theme.inkMuted
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.textXs
                    }

                    ColumnLayout {
                        visible: root.bluetoothService.enabled
                        Layout.fillWidth: true
                        spacing: root.theme.space1

                        Repeater {
                            model: root.bluetoothService.devices

                            BluetoothDeviceRow {
                                required property var modelData
                                Layout.fillWidth: true
                                theme: root.theme
                                label: modelData ? (modelData.name || modelData.deviceName || modelData.address || "Unknown device") : ""
                                address: modelData ? modelData.address : ""
                                iconSource: root.bluetoothService.deviceIcon(modelData)
                                connected: modelData ? modelData.connected : false
                                connecting: modelData ? (modelData.state === BluetoothDeviceState.Connecting) : false
                                statusText: root.bluetoothService.deviceStatus(modelData)
                                onConnectClicked: root.bluetoothService.connectDevice(modelData)
                                onDisconnectClicked: root.bluetoothService.disconnectDevice(modelData)
                                onClicked: root.bluetoothService.toggleDevice(modelData)
                            }
                        }

                        Text {
                            visible: !root.bluetoothService.devices.values || root.bluetoothService.devices.values.length === 0
                            Layout.fillWidth: true
                            Layout.topMargin: root.theme.space2
                            Layout.bottomMargin: root.theme.space2
                            text: root.bluetoothService.discovering ? "Searching for nearby devices..." : "No devices found. Tap Scan to search."
                            color: root.theme.inkMuted
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.textXs
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: sliderColumn.implicitHeight + root.theme.space3 * 2
                radius: root.theme.radiusCard
                color: root.theme.surfaceRaised
                border.width: root.theme.borderWidth
                border.color: root.theme.ink

                ColumnLayout {
                    id: sliderColumn

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: root.theme.space3
                    spacing: root.theme.space2

                    Ui.ValueSlider {
                        Layout.fillWidth: true
                        theme: root.theme
                        iconSource: Quickshell.shellDir + "/assets/icons/" + (root.audioService.muted ? "volume-muted.svg" : "volume-high.svg")
                        label: "Volume"
                        statusText: root.audioService.muted ? "Muted" : root.audioService.volumePercent + "%"
                        value: Math.min(1, root.audioService.volume)
                        enabled: root.audioService.ready
                        accent: root.theme.green
                        iconClickable: true
                        iconAccessibleName: root.audioService.statusText + ". Toggle mute"
                        onIconClicked: root.audioService.toggleMuted()
                        onUserChanged: (value) => {
                            return root.audioService.setVolume(value);
                        }
                    }

                    Ui.ValueSlider {
                        Layout.fillWidth: true
                        theme: root.theme
                        iconSource: Quickshell.shellDir + "/assets/icons/sun.svg"
                        label: "Brightness"
                        statusText: root.brightnessService.statusText
                        value: root.brightnessService.value
                        enabled: root.brightnessService.available
                        accent: root.theme.peach
                        onUserChanged: (value) => {
                            return root.brightnessService.setValue(value);
                        }
                    }

                }

            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: monthCalendar.implicitHeight + root.theme.space3 * 2
                radius: root.theme.radiusCard
                color: root.theme.surfaceRaised
                border.width: root.theme.borderWidth
                border.color: root.theme.ink

                MonthCalendar {
                    id: monthCalendar

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: root.theme.space3
                    theme: root.theme
                    calendarService: root.calendarService
                }

            }

        }

    }

}
