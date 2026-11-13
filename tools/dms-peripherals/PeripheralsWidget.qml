// Peripherals bar widget for DMS: mouse + Wolverine V3 Pro battery in the bar,
// a card per device (battery, charging, controller mode and onboard profile)
// in the popout. Data comes from scripts/bar/peripherals.sh as JSON; refreshed
// every minute for the bar and on every popout open.

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    readonly property string script: Quickshell.env("HOME") + "/.config/hypr/scripts/bar/peripherals.sh"
    property var mouse: null
    property var pad: null
    property bool loaded: false

    function refresh() {
        if (!proc.running)
            proc.running = true;
    }

    function padSummary(p) {
        if (!p) return "";
        if (p.awake) return p.pct + "%";
        return p.mode === "Xbox" ? "Xbox" : "–";
    }

    Process {
        id: proc
        command: [root.script]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    root.mouse = d.mouse;
                    root.pad = d.pad;
                    root.loaded = true;
                } catch (e) {
                    console.warn("peripherals: bad output from", root.script, e);
                }
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // ---- Bar ----------------------------------------------------------

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                visible: !!root.mouse
                name: "mouse"
                size: root.iconSize
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
            StyledText {
                visible: !!root.mouse
                text: root.mouse ? root.mouse.pct + "%" : ""
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                font.features: ({ "tnum": 1 })
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
            Item {
                visible: !!root.mouse && !!root.pad
                width: Theme.spacingS
                height: 1
            }
            DankIcon {
                visible: !!root.pad
                name: "sports_esports"
                size: root.iconSize
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
            StyledText {
                visible: !!root.pad
                text: root.padSummary(root.pad)
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                font.features: ({ "tnum": 1 })
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
            StyledText {
                visible: !root.mouse && !root.pad
                text: root.loaded ? "–" : "…"
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS
            DankIcon {
                name: root.pad ? "sports_esports" : "mouse"
                size: root.iconSize
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
            }
            StyledText {
                text: root.pad ? root.padSummary(root.pad) : (root.mouse ? root.mouse.pct + "%" : "–")
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // ---- Popout -------------------------------------------------------

    component Chip: StyledRect {
        id: chip
        property string label: ""
        property string icon: ""
        property bool accent: false
        implicitWidth: chipRow.implicitWidth + Theme.spacingM * 2
        implicitHeight: chipRow.implicitHeight + Theme.spacingXS * 2
        radius: height / 2
        color: accent ? Theme.primaryContainer : Theme.surfaceContainerHighest

        Row {
            id: chipRow
            anchors.centerIn: parent
            spacing: Theme.spacingXS
            DankIcon {
                visible: chip.icon !== ""
                name: chip.icon
                size: Theme.iconSizeSmall
                color: chip.accent ? Theme.primary : Theme.surfaceVariantText
                anchors.verticalCenter: parent.verticalCenter
            }
            StyledText {
                text: chip.label
                font.pixelSize: Theme.fontSizeSmall
                color: chip.accent ? Theme.primary : Theme.surfaceVariantText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    component DeviceCard: StyledRect {
        id: card
        property string icon: ""
        property string title: ""
        property string subtitle: ""
        property var pct: undefined // number, or undefined when unknown
        property bool charging: false
        default property alias chips: chipFlow.data

        width: parent ? parent.width : 0
        implicitHeight: cardCol.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius * 1.5
        color: Theme.surfaceContainerHigh

        Column {
            id: cardCol
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            Row {
                width: parent.width
                spacing: Theme.spacingM

                StyledRect {
                    id: iconBubble
                    width: 44
                    height: 44
                    radius: 22
                    color: Theme.primaryContainer
                    DankIcon {
                        anchors.centerIn: parent
                        name: card.icon
                        size: Theme.iconSize
                        color: Theme.primary
                    }
                }

                Column {
                    width: parent.width - iconBubble.width - pctText.width - Theme.spacingM * 2
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    StyledText {
                        width: parent.width
                        text: card.title
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.surfaceText
                        elide: Text.ElideRight
                    }
                    StyledText {
                        width: parent.width
                        visible: text !== ""
                        text: card.subtitle
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                    }
                }

                Row {
                    id: pctText
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    visible: card.pct !== undefined
                    DankIcon {
                        visible: card.charging
                        name: "bolt"
                        size: Theme.iconSizeSmall
                        color: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    StyledText {
                        text: card.pct !== undefined ? card.pct + "%" : ""
                        font.pixelSize: Theme.fontSizeXLarge
                        font.features: ({ "tnum": 1 })
                        color: card.pct !== undefined && card.pct <= 20 && !card.charging ? Theme.error : Theme.surfaceText
                    }
                }
            }

            // Battery bar
            Rectangle {
                visible: card.pct !== undefined
                width: parent.width
                height: 6
                radius: 3
                color: Theme.surfaceContainerHighest
                Rectangle {
                    width: parent.width * Math.max(0, Math.min(100, card.pct ?? 0)) / 100
                    height: parent.height
                    radius: parent.radius
                    color: card.pct <= 20 && !card.charging ? Theme.error : Theme.primary
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                }
            }

            Flow {
                id: chipFlow
                width: parent.width
                spacing: Theme.spacingS
                visible: children.length > 0
            }
        }
    }

    popoutWidth: 380
    popoutHeight: 420

    popoutContent: Component {
        PopoutComponent {
            id: popout
            headerText: "Peripherals"

            // Fresh read every time the popout opens
            Component.onCompleted: root.refresh()

            Column {
                width: parent.width
                spacing: Theme.spacingS

                DeviceCard {
                    visible: !!root.pad
                    icon: "sports_esports"
                    title: root.pad ? root.pad.name : ""
                    subtitle: !root.pad ? ""
                        : root.pad.mode === "Xbox" ? "Battery and profile need PC mode: Fn + Menu + A"
                        : !root.pad.awake ? "Asleep or off"
                        : ""
                    pct: root.pad && root.pad.awake ? root.pad.pct : undefined
                    charging: !!(root.pad && root.pad.charging)

                    Chip {
                        icon: root.pad && root.pad.mode === "PC" ? "computer" : "videogame_asset"
                        label: root.pad ? root.pad.mode + " mode" : ""
                        accent: true
                    }
                    Chip {
                        visible: !!(root.pad && root.pad.profile)
                        icon: "tune"
                        label: root.pad && root.pad.profile ? "Profile " + root.pad.profile : ""
                    }
                    Chip {
                        visible: !!(root.pad && root.pad.charging)
                        icon: "bolt"
                        label: "Charging"
                    }
                }

                DeviceCard {
                    visible: !!root.mouse
                    icon: "mouse"
                    title: root.mouse ? root.mouse.name : ""
                    pct: root.mouse ? root.mouse.pct : undefined
                    charging: !!(root.mouse && root.mouse.charging)

                    Chip {
                        visible: !!(root.mouse && root.mouse.charging)
                        icon: "bolt"
                        label: "Charging"
                    }
                }

                StyledText {
                    visible: root.loaded && !root.mouse && !root.pad
                    text: "No peripherals found"
                    color: Theme.surfaceVariantText
                }

                StyledText {
                    width: parent.width
                    visible: !!root.pad
                    topPadding: Theme.spacingXS
                    leftPadding: Theme.spacingS
                    text: "Profiles: Fn + A / B / X / Y\nModes: Fn + Menu + A (PC) · Fn + Menu + X (Xbox)"
                    lineHeight: 1.3
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
