import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io

QtObject {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: available && adapter.enabled
    readonly property bool discovering: available && adapter.discovering
    readonly property var devices: Bluetooth.devices
    property int revision: 0

    readonly property var connectedDevices: {
        const _ = revision;
        return findConnectedDevices();
    }
    readonly property int connectedCount: connectedDevices.length
    readonly property string connectedName: connectedCount > 0 ? (connectedDevices[0].name || connectedDevices[0].deviceName || connectedDevices[0].address) : ""
    readonly property string statusText: !available ? "Bluetooth unavailable" : (!enabled ? "Bluetooth off" : (connectedCount > 0 ? connectedName + " connected" : "Bluetooth on"))

    function findConnectedDevices() {
        const devs = Bluetooth.devices.values || [];
        const connected = [];
        for (let i = 0; i < devs.length; i++) {
            if (devs[i] && devs[i].connected)
                connected.push(devs[i]);
        }
        return connected;
    }

    function toggleEnabled() {
        if (available)
            adapter.enabled = !adapter.enabled;
    }

    function setEnabled(value) {
        if (available)
            adapter.enabled = Boolean(value);
    }

    function toggleDiscovery() {
        if (available && enabled) {
            adapter.discovering = !adapter.discovering;
        }
    }

    function connectDevice(device) {
        if (!device)
            return ;
        if (typeof device.connect === "function") {
            try {
                device.connect();
            } catch (e) {
                console.log("QML device.connect failed, falling back to bluetoothctl:", e);
            }
        }
        if (device.address) {
            btActionProcess.command = ["bluetoothctl", "connect", device.address];
            if (!btActionProcess.running)
                btActionProcess.running = true;
        }
        revision++;
    }

    function disconnectDevice(device) {
        if (!device)
            return ;
        if (typeof device.disconnect === "function") {
            try {
                device.disconnect();
            } catch (e) {
                console.log("QML device.disconnect failed, falling back to bluetoothctl:", e);
            }
        }
        if (device.address) {
            btActionProcess.command = ["bluetoothctl", "disconnect", device.address];
            if (!btActionProcess.running)
                btActionProcess.running = true;
        }
        revision++;
    }

    function toggleDevice(device) {
        if (!device)
            return ;
        if (device.connected)
            disconnectDevice(device);
        else
            connectDevice(device);
    }

    function deviceIcon(device) {
        if (!device)
            return Quickshell.shellDir + "/assets/icons/bluetooth.svg";
        const icon = String(device.icon || "").toLowerCase();
        if (icon.indexOf("head") >= 0 || icon.indexOf("audio") >= 0)
            return Quickshell.shellDir + "/assets/icons/headphones.svg";
        return Quickshell.shellDir + "/assets/icons/bluetooth.svg";
    }

    function deviceStatus(device) {
        if (!device)
            return "";
        if (device.connected) {
            if (device.batteryAvailable && device.battery >= 0) {
                const pct = device.battery <= 1.0 ? Math.round(device.battery * 100) : Math.round(device.battery);
                return "Connected (" + pct + "%)";
            }
            return "Connected";
        }
        if (device.state === BluetoothDeviceState.Connecting)
            return "Connecting...";
        if (device.state === BluetoothDeviceState.Disconnecting)
            return "Disconnecting...";
        if (device.paired)
            return "Paired";
        return "Ready";
    }

    property Process btActionProcess: Process {
        id: btActionProcess
        onExited: (exitCode, exitStatus) => {
            root.revision++;
        }
    }

    property Timer pollTimer: Timer {
        interval: 3000
        repeat: true
        running: root.enabled
        onTriggered: root.revision++
    }

    property Connections deviceConnections: Connections {
        target: Bluetooth.devices
        function onValuesChanged() {
            root.revision++;
        }
        function onObjectInsertedPost() {
            root.revision++;
        }
        function onObjectRemovedPost() {
            root.revision++;
        }
    }

}
