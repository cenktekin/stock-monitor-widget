import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

MouseArea {
    id: compactRoot
    property var rootItem

    implicitWidth: panelRow.implicitWidth + (Kirigami.Units.smallSpacing * 4)
    implicitHeight: panelRow.implicitHeight
    width: implicitWidth
    height: implicitHeight

    // Essential for Plasma to allocate space and prevent overlap
    Layout.minimumWidth: implicitWidth
    Layout.preferredWidth: implicitWidth

    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    onClicked: (mouse) => {
        if (mouse.button === Qt.MiddleButton) {
            // Visual feedback: brief flicker
            if (priceText) priceText.opacity = 0.3;
            rootItem.refreshData();
            timerFlicker.restart();
        } else {
            rootItem.expanded = !rootItem.expanded;
        }
    }

    Timer {
        id: timerFlicker
        interval: 300
        onTriggered: if (priceText) priceText.opacity = 1.0;
    }

    RowLayout {
        id: panelRow
        anchors.centerIn: parent
        spacing: 8

        ColumnLayout {
            spacing: -2
            Layout.alignment: Qt.AlignVCenter

            RowLayout {
                spacing: 4
                Text {
                    text: (rootItem.isMultiMode ? rootItem.panelTicker : rootItem.singleTicker).toUpperCase()
                    color: Kirigami.Theme.textColor
                    font.pixelSize: 9
                    font.weight: Font.Bold
                    opacity: 0.6
                    Layout.alignment: Qt.AlignBottom
                }
                Text {
                    text: rootItem.isPositive ? "▲" : "▼"
                    color: rootItem.isPositive ? rootItem.positiveColor : rootItem.negativeColor
                    font.pixelSize: 8
                    font.weight: Font.Bold
                }
            }

            RowLayout {
                spacing: 6
                Layout.alignment: Qt.AlignLeft

                Text {
                    id: priceText
                    text: rootItem.currentPrice
                    color: rootItem.isPositive ? rootItem.positiveColor : rootItem.negativeColor
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    // Ensure the price text is fully opaque; color is controlled by the line above
                    opacity: 1.0
                }

                Rectangle {
                    radius: 4
                    // Vertical Panel Support: Hide badge in vertical panels to avoid overlap
                    visible: rootItem.formFactor !== PlasmaCore.Types.Vertical && !rootItem.hideChangePercentage
                    // Background: translucent tint of the positive/negative color for theme independence
                    color: rootItem.isPositive
                           ? Qt.rgba(rootItem.positiveColor.r, rootItem.positiveColor.g, rootItem.positiveColor.b, 0.18)
                           : Qt.rgba(rootItem.negativeColor.r, rootItem.negativeColor.g, rootItem.negativeColor.b, 0.18)
                    border.color: rootItem.isPositive ? rootItem.positiveColor : rootItem.negativeColor
                    border.width: 1
                    Layout.preferredWidth: pctText2.implicitWidth + (Kirigami.Units.smallSpacing * 2)
                    Layout.preferredHeight: pctText2.implicitHeight + (Kirigami.Units.smallSpacing / 2)

                    Text {
                        id: pctText2
                        anchors.centerIn: parent
                        text: rootItem.percentChange
                        color: rootItem.isPositive ? rootItem.positiveColor : rootItem.negativeColor
                        font.pixelSize: 10
                        font.weight: Font.Black
                    }
                }
            }
        }
    }
}
