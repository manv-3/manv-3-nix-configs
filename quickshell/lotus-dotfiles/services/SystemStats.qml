import QtQuick
import Quickshell.Io
import Quickshell.Services.UPower

QtObject {
    id: root

    property bool active: false
    property bool cpuLoading: true
    property bool memoryLoading: true
    property bool cpuError: false
    property bool memoryError: false
    property int cpuUsage: 0
    property int memoryUsage: 0
    property string memoryDetailText: ""
    property double memoryUsedGiB: 0
    property double memoryTotalGiB: 0
    property double previousCpuIdle: 0
    property double previousCpuTotal: 0
    readonly property bool loading: cpuLoading || memoryLoading
    readonly property bool error: cpuError || memoryError
    readonly property var battery: UPower.displayDevice
    readonly property bool batteryAvailable: battery !== null && battery.ready && battery.isPresent && battery.isLaptopBattery
    readonly property int batteryPercent: {
        if (!batteryAvailable)
            return 0;
        const p = Number(battery.percentage) || 0;
        // Quickshell UPower percentage is 0.0 to 1.0 (e.g. 1.0 = 100%)
        return Math.max(0, Math.min(100, p <= 1.0 ? Math.round(p * 100) : Math.round(p)));
    }
    readonly property string batteryStateText: {
        if (!batteryAvailable)
            return "Unavailable";
        switch (battery.state) {
        case UPowerDeviceState.Charging:
            return "Charging";
        case UPowerDeviceState.Discharging:
            return "Discharging";
        case UPowerDeviceState.FullyCharged:
            return "Full";
        case UPowerDeviceState.PendingCharge:
            return "Pending charge";
        case UPowerDeviceState.PendingDischarge:
            return "Pending discharge";
        default:
            return "On battery";
        }
    }
    property Process cpuProcess
    property Process memoryProcess
    property Timer pollTimer
    property Timer primeTimer

    onActiveChanged: {
        if (active) {
            cpuLoading = true;
            memoryLoading = true;
            previousCpuTotal = 0;
            previousCpuIdle = 0;
            refresh();
            primeTimer.restart();
        } else {
            primeTimer.stop();
            previousCpuTotal = 0;
            previousCpuIdle = 0;
        }
    }

    function refresh() {
        if (!cpuProcess.running)
            cpuProcess.running = true;

        if (!memoryProcess.running)
            memoryProcess.running = true;

    }

    function parseCpu(output) {
        const firstLine = String(output).split("\n")[0].trim();
        const parts = firstLine.split(/\s+/);
        if (parts.length < 6 || parts[0] !== "cpu") {
            cpuError = true;
            return ;
        }
        let total = 0;
        for (let index = 1; index < parts.length; index++)
            total += Number(parts[index]) || 0;
        const idle = (Number(parts[4]) || 0) + (Number(parts[5]) || 0);
        const totalDelta = total - previousCpuTotal;
        const idleDelta = idle - previousCpuIdle;
        if (previousCpuTotal > 0 && totalDelta > 0) {
            cpuUsage = Math.max(0, Math.min(100, Math.round((1 - idleDelta / totalDelta) * 100)));
            cpuLoading = false;
        }

        previousCpuTotal = total;
        previousCpuIdle = idle;
        cpuError = false;
    }

    function parseMemory(output) {
        const text = String(output);
        const totalMatch = text.match(/^MemTotal:\s+(\d+)/m);
        const availableMatch = text.match(/^MemAvailable:\s+(\d+)/m);
        if (totalMatch === null || availableMatch === null) {
            memoryError = true;
            return ;
        }
        const totalKb = Number(totalMatch[1]);
        const availableKb = Number(availableMatch[1]);
        const usedKb = Math.max(0, totalKb - availableKb);
        memoryUsage = totalKb > 0 ? Math.max(0, Math.min(100, Math.round((usedKb / totalKb) * 100))) : 0;
        memoryTotalGiB = totalKb / 1048576;
        memoryUsedGiB = usedKb / 1048576;
        memoryDetailText = memoryUsedGiB.toFixed(1) + " / " + memoryTotalGiB.toFixed(1) + " GiB";
        memoryLoading = false;
        memoryError = false;
    }

    cpuProcess: Process {
        id: cpuProcess

        command: ["cat", "/proc/stat"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.cpuLoading = false;
                root.cpuError = true;
                return ;
            }
            root.parseCpu(cpuOutput.text);
        }

        stdout: StdioCollector {
            id: cpuOutput
        }

    }

    memoryProcess: Process {
        id: memoryProcess

        command: ["cat", "/proc/meminfo"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.memoryLoading = false;
                root.memoryError = true;
                return ;
            }
            root.parseMemory(memoryOutput.text);
        }

        stdout: StdioCollector {
            id: memoryOutput
        }

    }

    primeTimer: Timer {
        interval: 250
        repeat: false
        onTriggered: root.refresh()
    }

    pollTimer: Timer {
        interval: 1000
        repeat: true
        running: root.active
        triggeredOnStart: false
        onTriggered: root.refresh()
    }

}
