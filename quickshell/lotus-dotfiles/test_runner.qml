import QtQuick
import Quickshell
import Quickshell.Bluetooth
import "services" as Services
import "widgets" as Widgets

ShellRoot {
    id: testRoot

    Theme { id: lotusTheme }
    UserConfig { id: config }
    Services.ClockService { id: clockService }
    Services.AudioService { id: audioService }
    Services.NetworkService { id: networkService }
    Services.BluetoothService { id: bluetoothService }
    Services.NotificationService { id: notificationService; theme: lotusTheme; userConfig: config }
    Services.BrightnessService { id: brightnessService; userConfig: config; active: true }
    Services.SystemStats { id: systemStats; active: true }
    Services.SystemHealth { id: systemHealth; active: true }
    Services.CalendarService { id: calendarService; clockService: clockService }
    Services.SessionService { id: sessionService }
    Services.AttentionService { id: attentionService }

    Widgets.QuickPanel {
        id: qp
        theme: lotusTheme
        clockService: clockService
        audioService: audioService
        networkService: networkService
        bluetoothService: bluetoothService
        notificationService: notificationService
        brightnessService: brightnessService
        systemStats: systemStats
        calendarService: calendarService
        sessionService: sessionService
        attentionService: attentionService
        bluetoothMenuOpen: true
    }

    Widgets.ControlDashboard {
        id: cd
        theme: lotusTheme
        systemStats: systemStats
        systemHealth: systemHealth
    }

    Timer {
        id: assertTimer
        interval: 2000
        running: true
        onTriggered: {
            let passed = true;
            let failures = [];

            // 1. Temperature Sensor Test
            if (systemHealth.temperaturesError) {
                passed = false;
                failures.push("Temperature sensors reported error");
            }
            if (systemHealth.cpuTemperature <= 0) {
                passed = false;
                failures.push("CPU temperature not detected (got: " + systemHealth.cpuTemperature + ")");
            }
            console.log("PASS: Temperature sensors working: CPU=" + systemHealth.cpuTemperatureText + ", GPU=" + systemHealth.gpuTemperatureText + ", Drive=" + systemHealth.driveTemperatureText);

            // 2. Battery Icon Test
            if (systemStats.batteryAvailable) {
                if (systemStats.batteryPercent <= 1 && systemStats.battery.percentage > 0.05) {
                    passed = false;
                    failures.push("Battery percentage is stuck at " + systemStats.batteryPercent + " despite raw percentage=" + systemStats.battery.percentage);
                } else {
                    console.log("PASS: Battery percentage correctly scaled: " + systemStats.batteryPercent + "% (state: " + systemStats.batteryStateText + ")");
                }
            } else {
                console.log("INFO: Battery not present on this system, batteryAvailable=false");
            }

            // 3. Brightness Slider Test
            if (!brightnessService.available) {
                passed = false;
                failures.push("BrightnessService is not available (error: " + brightnessService.error + ")");
            } else {
                console.log("PASS: Brightness controller available: value=" + Math.round(brightnessService.value * 100) + "% statusText=" + brightnessService.statusText);
            }

            // 4. Realtime System Stats Test
            if (systemStats.cpuError) {
                passed = false;
                failures.push("CPU stats error");
            }
            if (systemStats.memoryError) {
                passed = false;
                failures.push("Memory stats error");
            }
            if (systemStats.memoryDetailText.length === 0) {
                passed = false;
                failures.push("Memory detail text empty");
            } else {
                console.log("PASS: Realtime system information: CPU=" + systemStats.cpuUsage + "% RAM=" + systemStats.memoryUsage + "% (" + systemStats.memoryDetailText + ") Net DL=" + systemHealth.downloadText + " UL=" + systemHealth.uploadText);
            }

            // 5. Bluetooth Device Chooser Test
            if (!bluetoothService.available) {
                console.log("INFO: Bluetooth adapter not available on this host");
            } else {
                if (typeof bluetoothService.connectDevice !== "function" || typeof bluetoothService.disconnectDevice !== "function") {
                    passed = false;
                    failures.push("BluetoothService missing device connection methods");
                }
                if (!qp.bluetoothMenuOpen) {
                    passed = false;
                    failures.push("QuickPanel bluetoothMenuOpen is false");
                }
                console.log("PASS: Bluetooth device chooser integrated: enabled=" + bluetoothService.enabled + ", discovering=" + bluetoothService.discovering + ", devices count=" + (bluetoothService.devices.values ? bluetoothService.devices.values.length : 0));
            }

            // 6. QuickPanel Power Menu and Session Actions Test
            if (qp.powerMenuOpen) {
                passed = false;
                failures.push("QuickPanel powerMenuOpen was expected to be initially false");
            }
            qp.powerMenuOpen = true;
            if (!qp.powerMenuOpen) {
                passed = false;
                failures.push("QuickPanel powerMenuOpen failed to toggle to true");
            }
            qp.choosePowerAction("poweroff", "Shut down the computer?", lotusTheme.coral);
            if (qp.pendingAction !== "poweroff" || qp.pendingLabel !== "Shut down the computer?") {
                passed = false;
                failures.push("QuickPanel choosePowerAction failed to record pendingAction and pendingLabel");
            }
            qp.resetTransientState();
            if (qp.powerMenuOpen || qp.pendingAction.length !== 0 || qp.pendingLabel.length !== 0) {
                passed = false;
                failures.push("QuickPanel resetTransientState failed to reset powerMenuOpen and pendingAction");
            }
            console.log("PASS: QuickPanel power menu and session actions toggle, confirm, and reset correctly");

            if (!passed) {
                console.error("FAILURES:\n" + failures.join("\n"));
                Qt.exit(1);
            } else {
                console.log("ALL AUTOMATED TESTS PASSED SUCCESSFULLY!");
                Qt.exit(0);
            }
        }
    }
}
