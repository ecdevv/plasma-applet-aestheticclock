// IMPORT
// QtQuick
import QtQml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Plasma Modules
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.private.mpris as Mpris
import org.kde.ksysguard.sensors as Sensors

// MAIN
PlasmoidItem {
    id: root
    
    // Loading Fonts
    FontLoader {
        id: defaultFont
        source: "../fonts/Hasteristico.ttf"
        onStatusChanged: {
            if (status === FontLoader.Ready) {
                console.log("✅ Font loaded:", name)
            } else if (status === FontLoader.Error) {
                console.log("❌ Font load failed. Falling back to system font.")
            }
        }
    }
    
    // Properties
    // Fonts
    property var fontFamily: defaultFont.status === FontLoader.Ready ? defaultFont.name : "Sans Serif"
    
    // Booleans
    property bool proportionalFont: Plasmoid.configuration.proportional_font
    property bool enableShadows: Plasmoid.configuration.enable_shadows
    property bool showDate: Plasmoid.configuration.show_date
    property bool showSysMon: Plasmoid.configuration.show_sys_mon
    property bool enableFillAnimation: Plasmoid.configuration.enable_fill_animation
    property bool enable24Hour: Plasmoid.configuration.enable_24_hour
    property bool useSystemColors: Plasmoid.configuration.use_system_colors 
    property bool removeLeadingZero: Plasmoid.configuration.remove_leading_zero

    // Font Sizes
    property int globalFontSize: Plasmoid.configuration.global_font_size 
    property int monthFontSize: proportionalFont ? globalFontSize * 0.24 : Plasmoid.configuration.month_font_size
    property int dayFontSize: proportionalFont ? globalFontSize * 0.54 : Plasmoid.configuration.day_font_size
    property int yearFontSize: proportionalFont ? globalFontSize * 0.19 : Plasmoid.configuration.year_font_size
    property int timeFontSize: proportionalFont ? globalFontSize * 1.25 : Plasmoid.configuration.time_font_size
    property int timeAPFontSize: proportionalFont ? globalFontSize * 0.24 : Plasmoid.configuration.timeap_font_size
    property int sysMonTextFontSize: proportionalFont ? globalFontSize * 0.19 : Plasmoid.configuration.sys_mon_text_font_size
    property int sysMonUsageFontSize: proportionalFont ? globalFontSize * 0.1 : Plasmoid.configuration.sys_mon_usage_font_size
    property int audioTitleFontSize: proportionalFont ? globalFontSize * 0.1 : Plasmoid.configuration.audio_title_font_size
    property int audioArtistFontSize: proportionalFont ? globalFontSize * 0.07 : Plasmoid.configuration.audio_artist_font_size
    property int nowPlayingFontSize: proportionalFont ? globalFontSize * 0.08: Plasmoid.configuration.now_playing_font_size
    property int audioImageWidth: proportionalFont ? globalFontSize * 0.25 : Plasmoid.configuration.audio_image_width
    
    // subtracting some amount of spacing because this font has really big line height
    property int sysMonSpacing: -50 + Plasmoid.configuration.sys_mon_spacing
    property int audioSpacing: -30 + Plasmoid.configuration.audio_spacing
    property int dateSpacing: -15 + Plasmoid.configuration.date_spacing
    
    // Other
    property int sysMonInterval: Plasmoid.configuration.sys_mon_interval

    // Color
    property color textBackgroundColor: useSystemColors ? PlasmaCore.Theme.backgroundColor : (Plasmoid.configuration.text_background_color || "#464a4b")
    property color colorOne: useSystemColors ? PlasmaCore.Theme.negativeTextColor : (Plasmoid.configuration.color_one || "#d78695")
    property color colorTwo: useSystemColors ? PlasmaCore.Theme.positiveTextColor : (Plasmoid.configuration.color_two || "#9ed24a")
    property color colorThree: useSystemColors ? PlasmaCore.Theme.neutralTextColor : (Plasmoid.configuration.color_three || "#dfa45c")

    // Plasmoid
    fullRepresentation: Item {
        id: widget
        Plasmoid.backgroundHints: (enableShadows ? PlasmaCore.Types.ShadowBackground : PlasmaCore.Types.NoBackground) | PlasmaCore.Types.ConfigurableBackground
        Layout.minimumWidth: wrapper.implicitWidth + 50
        Layout.minimumHeight: wrapper.implicitHeight + 50
        
        
        // Time Data Source
        Plasma5Support.DataSource {
            id: timeSource
            engine: "time"
            connectedSources: ["Local"]
            interval: 1000
            signal fillDataChanged
            property bool use24Hour: root.enable24Hour
            
            onDataChanged: {
                // 1. Parse date ONCE
                var curDate = new Date(timeSource.data["Local"]["DateTime"])
                
                var DAY = curDate.getDate()
                var HOUR = curDate.getHours()
                var HOURAP = HOUR % 12 || 12
                var MIN = curDate.getMinutes()
                var MONTH = curDate.getMonth() + 1 // Months are 0-indexed
                var YEAR = curDate.getFullYear()
                var SECOND = curDate.getSeconds()
                
                month.text = Qt.formatDate(curDate, "MMM") // Keep formatString only where needed
                year.text = YEAR
                timeAP.text = use24Hour ? ":" : Qt.formatTime(curDate, "AP")

                if (enable24Hour) {
                    // Use padStart instead of ternary logic
                    hours.text = removeLeadingZero ? HOUR : HOUR.toString().padStart(2, "0")
                } else {
                    hours.text = removeLeadingZero ? HOURAP : HOURAP.toString().padStart(2, "0")
                }
                
                day.text = DAY < 10 ? "0" + DAY : DAY
                minutes.text = MIN < 10 ? "0" + MIN : MIN
                
                if (enableFillAnimation) fillDataChanged()
            } 
            onUse24HourChanged: {
                dataChanged()
            }
            onFillDataChanged: {
                var curDate = new Date(timeSource.data["Local"]["DateTime"])

                var SECOND = curDate.getSeconds()
                var MIN = curDate.getMinutes()
                var HOUR = curDate.getHours()
                var DAY = curDate.getDate()
                var MONTH = curDate.getMonth() + 1
                var YEAR = curDate.getFullYear()
                
                // updating minute fill value each second, hour fill every minute, day fill every hour
                minutes.currentVal = SECOND
                hours.currentVal = MIN
                day.currentVal = HOUR + 1
                month.currentVal = DAY
                month.to = daysInMonth(MONTH, YEAR)
                year.currentVal = MONTH
                
                if (!use24Hour) {
                    timeAP.currentVal = (HOUR < 12) ? 1 : 2
                }
            }
        }
        
        // Return days in a month to get fill data for the current month
        function daysInMonth (month, year) {
            return new Date(year, month, 0).getDate();
        }   

        // System Monitor Data Sources (CPU Usage, RAM Usage, and System Uptime)
        Sensors.Sensor {
            id: cpuSensor
            sensorId: "cpu/all/usage"
            updateRateLimit: sysMonInterval
            onValueChanged: {
                if (!isNaN(value)) {
                    cpuUsage.usage = Math.round(value)
                } else {
                    cpuUsage.usage = ""
                }
            }
        }
        Sensors.Sensor {
            id: ramSensor
            sensorId: "memory/physical/usedPercent"
            updateRateLimit: sysMonInterval
            onValueChanged: {
                if (!isNaN(value)) {
                    ramUsage.usage = Math.round(value)
                } else {
                    ramUsage.usage = ""
                }
            }
        }
        Sensors.Sensor {
            id: uptimeSensor
            sensorId: "os/system/uptime"
            updateRateLimit: sysMonInterval
            onValueChanged: {
                // Update uptime
                if (uptimeSensor && uptimeSensor.value && !isNaN(uptimeSensor.value)) {
                    var up = uptimeSensor.value
                    if (up < 60) {
                        uptime.unit = "s"
                        uptime.from = 0
                        uptime.to = 60
                    } else if (up < 3600) {
                        uptime.unit = "m"
                        uptime.from = 0
                        uptime.to = 60
                        up = up / 60
                    } else if (up < 86400) {
                        uptime.unit = "h"
                        uptime.from = 0
                        uptime.to = 24
                        up = up / 3600
                    } else {
                        uptime.unit = "d"
                        uptime.from = 0
                        uptime.to = 365
                        up = up / 86400
                    }
                    uptime.usage = parseInt(up)
                } else {
                    uptime.usage = ""
                }
            }
        }

        // Music Data Source
        Mpris.Mpris2Model {
            id: musicSource
            property bool showAudio: Plasmoid.configuration.show_audio
            property bool choosePlayerAutomatically: Plasmoid.configuration.choose_auto_player

            property var sourceIdentity: choosePlayerAutomatically ? null : Plasmoid.configuration.choose_preferred_player
            readonly property bool ready: musicSource.currentPlayer ? true : false

            onDataChanged: {
                sectionAudio.visible = showAudio && ready;
            }

            // Update the player
            function updatePlayer() {
                // If set to automatic player detection, update visibility based on available players
                if (choosePlayerAutomatically || !sourceIdentity) {
                    sectionAudio.visible = showAudio && musicSource.rowCount() > 0;
                    return;
                }

                // If set to preferred player detection, update visibility based on the found player
                let playerFound = false;
                for (let i = 0; i < musicSource.rowCount(); ++i) {
                    let modelIndex = musicSource.index(i, 0);
                    let player = musicSource.data(modelIndex, Qt.UserRole + 1); // Full player object

                    // If preferred player found, set visibility and return here
                    if (player && player.identity === sourceIdentity) {
                        musicSource.currentIndex = i;
                        playerFound = true;
                        sectionAudio.visible = showAudio && musicSource.rowCount() > 0 && playerFound;
                        console.log("Preferred player set to:", player.identity);
                        return;
                    }
                }
                // If the preferred player is not found, fall back to the next available player, then update visiblity if player(s) are available
                if (!playerFound && musicSource.rowCount() > 0) {
                    musicSource.currentIndex = 0;  // Set to the first available player if the preferred player is not found
                    sectionAudio.visible = showAudio && musicSource.rowCount() > 0;
                    console.log("Preferred player not found. Falling back to the first available player.");
                    return
                }

                // If no players are found, update visibility
                sectionAudio.visible = showAudio && false;
                console.log("No players found:", sourceIdentity);
            }

            onRowsInserted: {
                updatePlayer()
            }

            onRowsRemoved: {
                updatePlayer()
            }

            onShowAudioChanged: {
                updatePlayer()
            }

            onChoosePlayerAutomaticallyChanged: {
                updatePlayer()
            }

            Plasmoid.contextualActions: [
                PlasmaCore.Action {
                    text: i18n("Update Data")
                    icon.name: "system-reboot"
                    onTriggered: {
                        if (musicSource) {
                            updatePlayer()
                        } else {
                            console.log("musicSource is not available");
                        }
                    }
                }
            ]
        }
        

        // Layout
        ColumnLayout {
            id: wrapper
            anchors.centerIn: parent
            RowLayout {
                id: sectionAudio
                Layout.fillWidth: true
                Layout.bottomMargin: audioSpacing
                Layout.alignment: Qt.AlignLeft
                spacing: 5

                ColumnLayout {
                    id: nowPlaying
                    property var fontSize: nowPlayingFontSize;
                    FontLabel {
                        fill: false
                        color: colorOne
                        text: "Now"
                        Layout.alignment: Qt.AlignRight
                        font.pixelSize: nowPlaying.fontSize
                    }
                    FontLabel {
                        fill: false
                        color: colorOne
                        text: "Playing"
                        Layout.alignment: Qt.AlignRight
                        font.pixelSize: nowPlaying.fontSize
                    }
                }
                Image {
                    source: musicSource.currentPlayer?.artUrl || ""
                    fillMode: Image.PreserveAspectCrop
                    Layout.maximumHeight: audioImageWidth
                    Layout.maximumWidth: audioImageWidth
                }
                ColumnLayout {
                    FontLabel {
                        text: musicSource.currentPlayer?.track || ""
                        color: colorTwo
                        fill: false
                        font.pixelSize: audioTitleFontSize
                        elide: Text.ElideRight
                        labelWidth: sectionTime.width - 35
                        Layout.alignment: Qt.AlignLeft
                    }
                    FontLabel {
                        // text: musicSource.currentPlayer?.artist || ""
                        text: musicSource.currentPlayer?.artist?.join(", ") || musicSource.currentPlayer?.artist || ""
                        color: colorThree
                        fill: false
                        font.pixelSize: audioArtistFontSize
                        elide: Text.ElideRight
                        labelWidth: sectionTime.width - 35
                        Layout.alignment: Qt.AlignLeft
                    }
                }
            }
            RowLayout {
                id: sectionDateTime
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 10
                ColumnLayout {
                    id: sectionDate
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    spacing: dateSpacing
                    visible: showDate
                    FontLabel {
                        id: month
                        font.pixelSize: monthFontSize
                        color: colorOne
                        from: 0
                    }
                    FontLabel {
                        id: day
                        font.pixelSize: dayFontSize
                        color: colorTwo
                        from: 0
                        to: 24
                    }
                    FontLabel {
                        id: year
                        font.pixelSize: yearFontSize
                        color: colorThree
                        from: 1
                        to: 12
                    }
                }
                RowLayout {
                    id: sectionTime
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    spacing: 10
                    FontLabel {
                        id: hours
                        font.pixelSize: timeFontSize
                        color: colorOne
                        from: 0
                        to: 60
                    }
                    FontLabel {
                        id: timeAP
                        font.pixelSize: timeAPFontSize
                        color: colorThree
                        from: 1
                        to: 2
                    }
                    FontLabel {
                        id: minutes
                        font.pixelSize: timeFontSize
                        color: colorTwo
                        from: 0
                        to: 60
                    }
                }
            }
            RowLayout {
                id: sectionSysMon
                Layout.fillWidth: true
                Layout.topMargin: sysMonSpacing
                Layout.alignment: Qt.AlignRight
                spacing: 5
                visible: showSysMon

                SysMonLabel {
                    id: cpuUsage
                    text: "CPU"
                    color: colorOne
                    from: 0
                    to: 100
                    unit: "%"
                }
                SysMonLabel {
                    id: ramUsage
                    text: "RAM"
                    color: colorTwo
                    from: 0
                    to: 100
                    unit: "%"
                }
                SysMonLabel {
                    id: uptime
                    text: "UPTIME"
                    color: colorThree
                }
            }
        }
    }
}
