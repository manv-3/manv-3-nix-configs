pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property int bars: 45
    property var _owners: ({})

    readonly property int refCount: Object.keys(_owners).length
    readonly property bool active: refCount > 0
    readonly property bool available: false
    readonly property var values: []

    function acquire(token) {
        if (!token || root._owners[token])
            return;

        const next = Object.assign({}, root._owners);
        next[token] = true;
        root._owners = next;
    }

    function release(token) {
        if (!token || !root._owners[token])
            return;

        const next = Object.assign({}, root._owners);
        delete next[token];
        root._owners = next;
    }
}
