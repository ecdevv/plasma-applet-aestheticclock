import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    // Properties
    property alias cfg_time_font_size: timeFontSize.value
    property alias cfg_month_font_size: monthFontSize.value
    property alias cfg_year_font_size: yearFontSize.value
    property alias cfg_day_font_size: dayFontSize.value
    property alias cfg_timeap_font_size: timeAPFontSize.value
    property alias cfg_sys_mon_text_font_size: sysMonTextFontSize.value
    property alias cfg_sys_mon_usage_font_size: sysMonUsageFontSize.value
    property alias cfg_audio_title_font_size: audioTitleFontSize.value
    property alias cfg_audio_artist_font_size: audioArtistFontSize.value
    property alias cfg_now_playing_font_size: nowPlayingFontSize.value
    property alias cfg_global_font_size: globalFontSize.value
    property alias cfg_audio_image_width: audioImageWidth.value

    property alias cfg_date_spacing: dateSpacing.value
    property alias cfg_audio_spacing: audioSpacing.value
    property alias cfg_sys_mon_spacing: sysMonSpacing.value

    property color cfg_text_background_color: Plasmoid.configuration.text_background_color
    property color cfg_color_one: Plasmoid.configuration.color_one
    property color cfg_color_two: Plasmoid.configuration.color_two
    property color cfg_color_three: Plasmoid.configuration.color_three

    property string defaultTextBackgroundColor: "#464a4b"
    property string defaultColorOne: "#d78695"
    property string defaultColorTwo: "#9ed24a"
    property string defaultColorThree: "#dfa45c"

    property alias cfg_proportional_font: proportionalFont.checked
    property alias cfg_enable_shadows: enableShadows.checked
    property alias cfg_show_sys_mon: showSysMon.checked
    property alias cfg_show_audio: showAudio.checked
    property alias cfg_enable_fill_animation: enableFillAnimation.checked
    property alias cfg_show_date: showDate.checked
    property alias cfg_enable_24_hour: enable24Hour.checked
    property alias cfg_use_system_colors: useSystemColors.checked
    property alias cfg_remove_leading_zero: removeLeadingZero.checked

    Kirigami.FormLayout {
        id: form
        anchors.centerIn: parent

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Font Customization")
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Use Proportional Font Size")
            CheckBox {
                id: proportionalFont

            }
            SpinBox {
                id: globalFontSize
                from: 0
                to: 1000
                enabled: proportionalFont.checked
            }
        }
        SpinBox {
            id: yearFontSize
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("Year")
            enabled: !proportionalFont.checked
        }
        SpinBox {
            id: monthFontSize
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("Month")
            enabled: !proportionalFont.checked
        }
        SpinBox {
            id: dayFontSize
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("Day")
            enabled: !proportionalFont.checked
        }
        SpinBox {
            id: timeFontSize
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("Time")
            enabled: !proportionalFont.checked
        }
        SpinBox {
            id: timeAPFontSize
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("AM/PM")
            enabled: !proportionalFont.checked
        }
        SpinBox {
            id: sysMonTextFontSize
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("System Monitor Title")
            enabled: !proportionalFont.checked
        }
        SpinBox {
            id: sysMonUsageFontSize
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("System Monitor Usage")
            enabled: !proportionalFont.checked
        }
        SpinBox {
            id: audioTitleFontSize
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("Music Title")
            enabled: !proportionalFont.checked
        }
        SpinBox {
            id: audioArtistFontSize
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("Music Artist")
            enabled: !proportionalFont.checked
        }
        SpinBox {
            id: nowPlayingFontSize
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("\"Now Playing\" Text")
            enabled: !proportionalFont.checked
        }
        SpinBox {
            id: audioImageWidth
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("Music Thumbnail Width")
            enabled: !proportionalFont.checked
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Font Spacing"
        }
        SpinBox {
            id: dateSpacing
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("Spacing between the time values.")
        }
        SpinBox {
            id: sysMonSpacing
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("Spacing between system monitor and time.")
        }
        SpinBox {
            id: audioSpacing
            from: 0
            to: 1000
            Kirigami.FormData.label: i18n("Spacing between audio and time.")
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Font Color"
        }
        // CheckBox {
        //     id: useSystemColors
        //     Kirigami.FormData.label: i18n("Use Current Color Scheme")
        // }

        Kirigami.FormLayout {
            anchors.horizontalCenter: parent.horizontalCenter

            ColorButton {
                id: textBackgroundColor
                Kirigami.FormData.label: i18n("Text Background Color")
                value: cfg_text_background_color
                onValueChanged: {
                    cfg_text_background_color = value
                }
            }
            ColorButton {
                id: colorOne
                Kirigami.FormData.label: i18n("Color 1")
                value: cfg_color_one
                onValueChanged: {
                    cfg_color_one = value
                }
            }
            ColorButton {
                id: colorTwo
                Kirigami.FormData.label: i18n("Color 2")
                value: cfg_color_two
                onValueChanged: {
                    cfg_color_two = value
                }
            }
            ColorButton {
                id: colorThree
                Kirigami.FormData.label: i18n("Color 3")
                value: cfg_color_three
                onValueChanged: {
                    cfg_color_three = value
                }
            }

            Button {
                text: i18n("Reset to Default")
                icon.name: "edit-undo"

                onClicked: {
                    cfg_text_background_color = defaultTextBackgroundColor
                    cfg_color_one = defaultColorOne
                    cfg_color_two = defaultColorTwo
                    cfg_color_three = defaultColorThree
                }
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Visibility")
        }
        CheckBox {
            id: enableShadows
            Kirigami.FormData.label: i18n("Enable Shadows")
        }
        CheckBox {
            id: showDate
            Kirigami.FormData.label: i18n("Show Date")
        }
        CheckBox {
            id: showSysMon
            Kirigami.FormData.label: i18n("Show System Monitor")
        }
        CheckBox {
            id: showAudio
            Kirigami.FormData.label: i18n("Show \"Now Playing\"")
        }
        CheckBox {
            id: enableFillAnimation
            Kirigami.FormData.label: i18n("Show Fill Animation")
        }
        CheckBox {
            id: enable24Hour
            Kirigami.FormData.label: i18n("Use 24 Hour clock")
        }
        CheckBox {
            id: removeLeadingZero
            Kirigami.FormData.label: i18n("Remove Leading Zero")
        }
    }
}
