import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.private.mpris as Mpris

// Config setup stolen from/credit goes to CatWalk widget by driglu4it
KCM.SimpleKCM {
    property alias cfg_sys_mon_interval: sysMonInterval.value
    property alias cfg_choose_auto_player: choosePlayerAutomatically.checked
    property var cfg_choose_preferred_player

    Kirigami.FormLayout {
        id: form

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("System Monitor")
        }
        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter

            Label {
                text: i18n("Interval (in milliseconds)")
                Layout.alignment: Qt.AlignVCenter
            }

            SpinBox {
                id: sysMonInterval
                from: 0
                to: 999999
                stepSize: 1000
                Layout.alignment: Qt.AlignVCenter
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Playback Source")
        }

        ButtonGroup {
            id: playerSourceRadio
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Player:")
            RadioButton {
                id: choosePlayerAutomatically
                text: i18n("Choose automatically")
                checked: cfg_choose_auto_player
                ButtonGroup.group: playerSourceRadio
            }
            Kirigami.ContextualHelpButton {
                toolTipText: i18n(
                    "The player will be chosen automatically based on the currently playing song." +
                    "If two or more players are playing at the same time, the widget will choose " +
                    "the one that started playing first."
                )
            }
        }

        RowLayout {
            RadioButton {
                id: selectPreferredPlayer
                text: i18n("Preferred:")
                checked: !cfg_choose_auto_player
                ButtonGroup.group: playerSourceRadio
            }

            ComboBox {
                enabled: selectPreferredPlayer.checked
                id: playerComboBox
                model: sources
                Component.onCompleted: {
                    const preferredPlayerIndex = playerComboBox.find(cfg_choose_preferred_player)
                    playerComboBox.currentIndex = preferredPlayerIndex != -1 ? preferredPlayerIndex : 0
                }
                onCurrentValueChanged: {
                    if (currentValue) {
                        cfg_choose_preferred_player = currentValue
                    }
                }
            }

            Button {
                enabled: selectPreferredPlayer.checked
                icon.name: 'refreshstructure'
                onClicked: {
                    sources.reload(cfg_choose_preferred_player)
                    const preferredPlayerIndex = playerComboBox.find(cfg_choose_preferred_player)
                    playerComboBox.currentIndex = preferredPlayerIndex != -1 ? preferredPlayerIndex : 0
                }
            }

            Kirigami.ContextualHelpButton {
                toolTipText: i18n(
                    "Select your preferred player to be prioritized. The widget will fallback to the " +
                    "first player source if available, otherwise it will hide itself. In the dropdown " +
                    "you can choose between all the players that are currently running. If you can't " +
                    "find the one you want, open or restart the player application and hit the reload " +
                    "button."
                )
            }
        }
    }

    ListModel {
        property var mpris2Model: Mpris.Mpris2Model {}

        id: sources
        function reload(predefinedSource) {
            sources.clear()
            if (predefinedSource) {
                sources.append({ "text": predefinedSource })
            }

            const CONTAINER_ROLE = Qt.UserRole + 1
            for (var i = 1; i < mpris2Model.rowCount(); i++) {
                const player = mpris2Model.data(mpris2Model.index(i, 0), CONTAINER_ROLE)
                if (predefinedSource !== player.identity) {
                    sources.append({ "text": player.identity })
                }
            }
        }
        Component.onCompleted: reload(cfg_choose_preferred_player)
    }
}
