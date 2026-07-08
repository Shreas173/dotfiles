pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: niriUtils

    property var outputWorkspaces: ({})
    property var workspaceIds: []
    property var maxIds: ({})

    function activeWorkspaceForOutput(outputName: string): int {
        if (niriUtils.outputWorkspaces[outputName] !== undefined) {
            return niriUtils.outputWorkspaces[outputName].activeIdx
        }
        return 1
    }

    function workspaceIndicesForOutput(outputName: string): var {
        if (niriUtils.outputWorkspaces[outputName] !== undefined) {
            return niriUtils.outputWorkspaces[outputName].indices
        }
        return [1]
    }

    function updateWorkspaces() {
        if (!workspacesProc.running) {
            workspacesProc.running = true
        }
    }

    function switchWorkspace(w: int): void {
        switchProc.command = ["niri", "msg", "action", "focus-workspace", String(w)]
        switchProc.running = true
    }

    function parseWorkspaces(parsed: var): void {
        var newMap = {}
        var sortedNames = []

        for (var i = 0; i < parsed.length; i++) {
            var ws = parsed[i]
            var output = ws.output
            if (output === null || output === undefined) continue

            if (newMap[output] === undefined) {
                newMap[output] = { activeIdx: 1, indices: [] }
                sortedNames.push(output)
            }

            var data = newMap[output]
            data.indices.push(ws.idx)

            if (ws.is_active) {
                data.activeIdx = ws.idx
            }
        }

        for (var j = 0; j < sortedNames.length; j++) {
            newMap[sortedNames[j]].indices.sort(function(a, b) { return a - b })
        }

        niriUtils.outputWorkspaces = newMap
        niriUtils.workspaceIds = sortedNames.sort()
    }

    Process {
        id: workspacesProc
        command: ["niri", "msg", "--json", "workspaces"]

        stdout: SplitParser {
            onRead: data => {
                try {
                    var parsed = JSON.parse(data)
                    niriUtils.parseWorkspaces(parsed)
                } catch (e) {
                    console.log("NiriUtils: Failed to parse workspaces:", e)
                }
            }
        }
    }

    Process {
        id: switchProc
        running: false
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: niriUtils.updateWorkspaces()
    }
}
