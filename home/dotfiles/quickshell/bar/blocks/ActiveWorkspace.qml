import QtQuick
import Quickshell.Io
import "../"

BarText {
  property int chopLength
  property string activeWindowTitle

  Process {
    id: titleProc
    command: ["sh", "-c", "niri msg --json focused-window 2>/dev/null | sed 's/.*\"title\":\"\\([^\"]*\\)\".*/\\1/'"]
    running: true

    stdout: SplitParser {
      onRead: data => {
        if (data.length > 0) activeWindowTitle = data
      }
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: titleProc.running = true
  }
}
